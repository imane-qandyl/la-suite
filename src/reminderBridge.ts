import { registerPlugin } from '@capacitor/core'

export interface ReminderItem {
  id: string
  text: string
  date: string // ISO8601
}

export interface ReminderState {
  on: boolean
  reminders: ReminderItem[]
}

export interface ReminderBridgePlugin {
  getReminderState(): Promise<ReminderState>
  setReminderState(options: { on: boolean }): Promise<void>
}

export const ReminderBridge = registerPlugin<ReminderBridgePlugin>('ReminderBridge')
