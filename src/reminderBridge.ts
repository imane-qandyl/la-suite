import { registerPlugin } from '@capacitor/core'

export interface ReminderState {
  on: boolean
  text?: string
  date?: string
}

export interface ReminderBridgePlugin {
  getReminderState(): Promise<ReminderState>
  setReminderState(options: { on: boolean }): Promise<void>
}

export const ReminderBridge = registerPlugin<ReminderBridgePlugin>('ReminderBridge')
