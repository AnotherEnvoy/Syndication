import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Collapsible, Flex, Button, Tooltip, Section, Divider} from '../components';

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

function GetPageUI(page) {
  if(page === Page.Home) {
    return <HomePage/>;
  }
  if(page == Page.Link) {
    return "unimplimented";
  }
  return <RelatedPage nodeID={page}/>;
}

function getLists(context) {
  const { data } = useBackend(context);
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

export const RDConsole = (props, context) => {
  const [page] = useLocalState(context, "page", Page.Home)
  return (
    <Window resizable title="R&D Console" width="2000">
      <Window.Content scrollable>
        <TopBar/>
        {GetPageUI(page)}
      </Window.Content>
    </Window>
  );
};

const TopBar = (props, context) => {
  const {data} = useBackend(context);
  const [_, setPage] = useLocalState(context, "page", Page.Home)
  return (
    <Flex>
      <Flex.Item><Button icon="home" mr="1em" onClick={() => setPage(Page.Home)}/></Flex.Item>
      <Flex.Item><Button icon="cog" onClick={() => setPage(Page.Link)}/></Flex.Item>
      <Flex.Item textAlign="right" grow={1} bold>Available: {data.credits}¢</Flex.Item>
    </Flex>
  )
}

const HomePage = (props, context) => {
    const {researched, available, future} = getLists(context)
    return (
      <Box>
        <Box width="25vw" bold inline textAlign="center">Researched</Box>
        <Box width="40vw" bold inline textAlign="center">Available</Box>
        <Box width="25vw" bold inline textAlign="center">Future</Box>
        <Box>
          {nodesToStack(researched, "25vw")}
          {nodesToStack(available, "40vw", true)}
          {nodesToStack(future, "25vw")}
        </Box>
      </Box>
    )
}

const RelatedPage = (props, context) => {
  const { data } = useBackend(context);
  const {nodeID} = props;
  const node = data.nodes[nodeID];
  return (
    <Box>
      <Box width="30vw" bold inline textAlign="center">Prerequisites</Box>
      <Box width="30vw" bold inline textAlign="center">Current Node</Box>
      <Box width="30vw" bold inline textAlign="center">Unlocks</Box>
      <Box mt="0.5em">
        {nodesToStack(Array.isArray(node.prereq_ids) ? node.prereq_ids : Object.keys(node.prereq_ids), "30vw", true)}
        <Box width="30vw" inline ml="1em"><ResearchCard nodeID={nodeID} showResearchStatus/></Box>
        {nodesToStack(Array.isArray(node.unlock_ids) ? node.unlock_ids : Object.keys(node.unlock_ids), "30vw", true)}
      </Box>
    </Box>
  )
}

const ResearchStatus = (props, context) => {
  const {act, data} = useBackend(context);
  const {nodeID} = props;
  const node = data.nodes[nodeID]
  if(data.researched_nodes[nodeID] != undefined) {
    return <Button disabled>Researched</Button>;
  }
  if(data.available_nodes[nodeID] == undefined) {
    return <Button disabled>Locked</Button>;
  }
  return <Button disabled={data.credits < node.cost} onClick={() => act("research", {nodeID: nodeID})}>
            Purchase ({node.cost}¢)
         </Button>;
}

const ResearchCard = (props, context) => {
  const { data } = useBackend(context)
  const {nodeID, showResearchStatus} = props
  const node = data.nodes[nodeID]
  const [_, setPage] = useLocalState(context, "page", Page.Home)
  return (
    <Box backgroundColor="rgba(70,0,0,0.8)" width="inherit" style={{outline: "2px solid rgba(0,0,0,0.2)"}}>
      <Collapsible title={node.name} color="none" buttons={showResearchStatus && (<ResearchStatus nodeID={nodeID}/>)}>
        <Box ml="1em">
          {node.description}
          <Flex wrap="wrap" align="center">
            <Flex.Item>
              <Button onClick={() => setPage(nodeID)}>
                Related
              </Button>
            </Flex.Item>
            {Object.keys(node.design_ids).map(id => (
            <Flex.Item>
              <Tooltip content={data.designs[id].name}>
                <span class={data.designs[id].icon}/>
              </Tooltip>
            </Flex.Item>))}
          </Flex>
        </Box>
      </Collapsible>
    </Box>
  )
}
