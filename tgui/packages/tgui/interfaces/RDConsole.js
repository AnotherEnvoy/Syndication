import { useBackend, useLocalState } from '../backend'
import { Window } from '../layouts'
import { Box, Flex, Button, Tooltip, Section, Input, Icon, Dropdown} from '../components'

export const RDConsole = (props, context) => {
  const [page] = useLocalState(context, "page", Page.Home)
  return (
    <Window title="R&D Console" width="2000" height="1000">
      <Window.Content scrollable fitted>
        <TopBar/>
        {getPageUI(page)}
      </Window.Content>
    </Window>
  )
}

function removeFromSet(set, toRemove) {
  for(const elem of toRemove) {
    set.delete(elem)
  }
}

function nodesToStack(nodes, width, showResearchStatus = null) {
  return (
    <Flex direction="column" width={width} inline ml="1em">
      {nodes.map(id => (
        <Flex.Item>
          <ResearchCard nodeID={id} showResearchStatus={showResearchStatus}/>
        </Flex.Item>
      ))}
    </Flex>)
}

const Page = {
  Home: 'PAGE_HOME',
  Link: 'PAGE_LINK'
}

function getPageUI(page) {
  if(page === Page.Home) {
    return <HomePage/>
  }
  if(page == Page.Link) {
    return <LinkPage/>
  }
  return <RelatedPage nodeID={page}/>
}

function getLists(context) {
  const { data } = useBackend(context)
  let researched = Object.keys(data.researched_nodes)
  let available = new Set(Object.keys(data.available_nodes))
  removeFromSet(available, researched)
  let future = new Set(Object.keys(data.visible_nodes))
  removeFromSet(future, researched)
  removeFromSet(future, available)
  available = Array.from(available)
  future = Array.from(future)
  return {researched: researched, available: available, future: future}
}

const TopBar = (props, context) => {
  const {data} = useBackend(context)
  const [_, setPage] = useLocalState(context, "page", Page.Home)
  return (
    <Flex mb="1em" backgroundColor="rgba(0,0,0,0.25)" p="1em">
      <Flex.Item><Button icon="home" mr="1em" onClick={() => setPage(Page.Home)}/></Flex.Item>
      <Flex.Item><Button icon="cog" onClick={() => setPage(Page.Link)}/></Flex.Item>
      <Flex.Item textAlign="center" grow={1}>Last Action: {data.research_logs.length > 0 ? data.research_logs[data.research_logs.length - 1] : "None"}</Flex.Item>
      <Flex.Item bold>Available: {data.credits}¢</Flex.Item>
    </Flex>
  )
}

function arraySetOverlap(arr, set) {
  for(const a in arr)
    if(set.has(a))
      return true
  return false
}

function performSearch(context, search) {
  const {data} = useBackend(context)
  if(search.text === "")
    return data.nodes
  let filteredDesigns = new Set()
  let filteredNodes = []
  if(search.type == "designs")
    for(const [key, value] of Object.entries(data.designs))
      if(value.name.toLowerCase().indexOf(search.text.toLowerCase()) >= 0)
        filteredDesigns.add(key)
  for(const [key,value] of Object.entries(data.nodes))
    if (((search.type === "name" && value.name.toLowerCase().indexOf(search.text.toLowerCase()) >= 0) ||
        (search.type === "description" && value.description.toLowerCase().indexOf(search.text.toLowerCase()) >= 0) ||
        (search.type === "designs" && arraySetOverlap(value.design_ids, filteredDesigns))))
        filteredNodes.push(key)
  return filteredNodes
}

const HomePage = (props, context) => {
  const {data} = useBackend(context)
    let {researched, available, future} = getLists(context)
    const [search, setSearch] = useLocalState(context, "search", {type: "name", text: ""})
    const [searchResult, setSearchResult] = useLocalState(context, "searchResult", Object.keys(data.nodes))
    const filter = (nodeID) => searchResult.indexOf(nodeID) !== -1
    researched = researched.filter(filter)
    available = available.filter(filter)
    future = future.filter(filter)
    return (
      <Box>
        <Box width="25vw" bold inline textAlign="center">Researched</Box>
        <Box width="40vw" bold inline textAlign="center">Available</Box>
        <Box width="25vw" bold inline textAlign="center">Future</Box>
        <Flex>
          <Flex.Item>
            <Icon name="search"/>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Input fluid onChange={(e, value) => {
              search.text = value
              setSearch(search)
              setSearchResult(performSearch(context, search))
            }} backgroundColor="rgba(0,0,0,0.3)"/>
          </Flex.Item>
          <Flex.Item>
            <Dropdown onSelected={(value) => {
              search.type = value
              setSearch(search)
              setSearchResult(performSearch(context, search))
            }} options={["name", "description", "designs"]} selected="name" backgroundColor="rgba(0,0,0,0.3)"/>
          </Flex.Item>
        </Flex>
        <Box>
          {nodesToStack(researched, "25vw")}
          {nodesToStack(available, "40vw", true)}
          {nodesToStack(future, "25vw")}
        </Box>
      </Box>
    )
}

const RelatedPage = (props, context) => {
  const { data } = useBackend(context)
  const {nodeID} = props
  const node = data.nodes[nodeID]
  return (
    <Box>
      <Box width="30vw" bold inline textAlign="center">Prerequisites</Box>
      <Box width="30vw" bold inline textAlign="center">Current Node</Box>
      <Box width="30vw" bold inline textAlign="center">Unlocks</Box>
      <Box mt="0.5em">
        {nodesToStack(Array.isArray(node.prereq_ids) ? node.prereq_ids : Object.keys(node.prereq_ids), "30vw", true)}
        {nodesToStack([nodeID], "30vw", true)}
        {nodesToStack(Array.isArray(node.unlock_ids) ? node.unlock_ids : Object.keys(node.unlock_ids), "30vw", true)}
      </Box>
    </Box>
  )
}

const LinkPage = (props, context) => {
  const { act, data } = useBackend(context)
  const { has_lathe, has_destroy, has_imprinter } = data
  let list_items = []
  if(has_lathe) {
    list_items.push(<li>Protolathe <Button onClick={() => act("disconnect", {device: "lathe"})}>Disconnect</Button></li>)
  }
  if(has_destroy) {
    list_items.push(<li>Destructive Analyzer <Button onClick={() => act("disconnect", {device: "destroy"})}>Disconnect</Button></li>)
  }
  if(has_imprinter) {
    list_items.push(<li>Circuit Imprinter <Button onClick={() => act("disconnect", {device: "imprinter"})}>Disconnect</Button></li>)
  }
  return (
    <Box mt="1em">
      <Section title="Connected Devices" buttons={<Button onClick={() => act("sync")}>Resync Devices</Button>}>
        <ul>
          {list_items}
        </ul>
      </Section>
      <Section title="Logs">
        <ul>
          {data.research_logs.slice(0).reverse().map(log => <li>{log}</li>)}
        </ul>
      </Section>
    </Box>
  )
}

const ResearchStatus = (props, context) => {
  const {act, data} = useBackend(context)
  const {nodeID} = props
  const node = data.nodes[nodeID]
  if(data.researched_nodes[nodeID] != undefined) {
    return <Button disabled>Researched</Button>
  }
  if(data.available_nodes[nodeID] == undefined) {
    return <Button disabled>Locked</Button>
  }
  return <Button disabled={data.credits < node.cost} onClick={() => act("research", {nodeID: nodeID})}>
            Purchase ({node.cost}¢)
         </Button>
}

const ResearchCard = (props, context) => {
  const { data } = useBackend(context)
  const {nodeID, showResearchStatus} = props
  const node = data.nodes[nodeID]
  const [_, setPage] = useLocalState(context, "page", Page.Home)
  return (
    <Section mt="1em" title={node.name} buttons={
      <Box>
        <Button mr="0.5em" onClick={() => setPage(nodeID)}>Related</Button>
        {showResearchStatus && <ResearchStatus nodeID={nodeID}/>}
      </Box>}>
      <Box ml="1em">
        {node.description}
        <Flex wrap="wrap" align="center" mt="0.5em">
          {Object.keys(node.design_ids).map(id => (
          <Flex.Item>
            <Tooltip content={data.designs[id].name}>
              <span class={data.designs[id].icon}/>
            </Tooltip>
          </Flex.Item>))}
        </Flex>
      </Box>
    </Section>
  )
}
