import { useBackend } from '../backend'
import { Window } from '../layouts'
import { Slider, Flex, LabeledList, Button } from '../components'
import { formatPower } from '../format'

const POWER_MUL = 1e3

export const Etm = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    requested,
    max_transmit,
    transmitted,
    price,
    account_holder
  } = data
  const earnings = transmitted * price
  return (
    <Window
      width={340}
      height={350}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Transmitting">
            {formatPower(transmitted)}
          </LabeledList.Item><LabeledList.Item label="Target">
            <Flex inline width="100%">
              <Flex.Item>
                <Button
                  icon="fast-backward"
                  disabled={requested === 0}
                  onClick={() => act('target', {
                    target: 'min',
                  })} />
                <Button
                  icon="backward"
                  disabled={requested === 0}
                  onClick={() => act('target', {
                    adjust: -10000,
                  })} />
              </Flex.Item>
              <Flex.Item grow={1} mx={1}>
                <Slider
                  value={requested / POWER_MUL}
                  minValue={0}
                  maxValue={max_transmit / POWER_MUL}
                  step={Math.ceil(max_transmit / POWER_MUL / 100)}
                  format={value => formatPower(value * POWER_MUL, 1)}
                  onDrag={(e, value) => act('target', {
                    target: value * POWER_MUL,
                  })} />
              </Flex.Item>
              <Flex.Item>
                <Button
                  icon="forward"
                  disabled={requested === max_transmit}
                  onClick={() => act('target', {
                    adjust: 10000,
                  })} />
                <Button
                  icon="fast-forward"
                  disabled={requested === max_transmit}
                  onClick={() => act('target', {
                    target: 'max',
                  })} />
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label="Earning">
            {earnings + " credits/s"}
          </LabeledList.Item>
          <LabeledList.Item label="Account">
            <Flex inline width="100%">
              <Flex.Item>
                {account_holder}
              </Flex.Item>
              <Flex.Item>
                <Button onClick={() => act('reset_account')}>
                  Reset
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  )
}
