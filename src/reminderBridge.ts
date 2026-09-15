import { registerPlugin } from '@capacitor/core'

export interface ReminderBridgePlugin {
  getReminderState(): Promise<{ on: boolean }>
  setReminderState(options: { on: boolean }): Promise<void>
}

export const ReminderBridge = registerPlugin<ReminderBridgePlugin>('ReminderBridge')
