import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Collapsible, Flex, Button} from '../components';

function removeFromSet(set, toRemove) {
  for(const elem of toRemove) {
    set.delete(elem)
  }
}

function nodesToStack(nodes, width, showResearchButton = null) {
  return (
    <Flex direction="column" width={width} inline ml="1em">
      {nodes.map(id => (
        <Flex.Item>
          <ResearchCard nodeID={id} showResearchButton={showResearchButton}/>
        </Flex.Item>
      ))}
    </Flex>)
}

export const RDConsole = (props, context) => {
  const { act, data } = useBackend(context);
  let researched = Object.keys(data.researched_nodes)
  let available = new Set(Object.keys(data.available_nodes))
  removeFromSet(available, researched)
  let future = new Set(Object.keys(data.visible_nodes))
  removeFromSet(future, researched)
  removeFromSet(future, available)
  available = Array.from(available)
  future = Array.from(future)
  return (
    <Window resizable title="R&D Console">
      <Window.Content scrollable>
        <Box>Available Credits: {data.credits}</Box>
        <Box width="25vw" bold inline textAlign="center">Researched</Box>
        <Box width="40vw" bold inline textAlign="center">Available</Box>
        <Box width="25vw" bold inline textAlign="center">Future</Box>
        {nodesToStack(researched, "25vw")}
        {nodesToStack(available, "40vw", true)}
        {nodesToStack(future, "25vw")}
      </Window.Content>
    </Window>
  );
};

const ResearchCard = (props, context) => {
  const { act, data } = useBackend(context);
  const {nodeID, showResearchButton} = props;
  const node = data.nodes[nodeID]

  return (
    <Box backgroundColor="rgba(70,0,0,0.8)" width="inherit">
      <Collapsible title={node.name} color="none" buttons={showResearchButton && (
        <Button onClick={() => act("research", {nodeID: nodeID})}>Buy for {node.cost}</Button>
      )}>
        <Box ml="1em">
          {node.description}
          <Flex wrap="wrap" align="center">
            {Object.keys(node.design_ids).map(id => (<Flex.Item title={data.designs[id].name}><span class={data.designs[id].icon}/></Flex.Item>))}
          </Flex>
        </Box>
      </Collapsible>
    </Box>
  )
}
