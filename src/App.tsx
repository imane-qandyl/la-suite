import { App as CapacitorApp } from '@capacitor/app'
import { Capacitor } from '@capacitor/core'
import { useCallback, useEffect, useState } from 'react'
import { type ReminderItem, ReminderBridge } from './reminderBridge'
import './App.css'

function App() {
  const [reminderOn, setReminderOn] = useState(false)
  const [reminders, setReminders] = useState<ReminderItem[]>([])

  const syncReminderState = useCallback(async () => {
    if (!Capacitor.isNativePlatform()) {
      return
    }

    const raw = await ReminderBridge.getReminderState()
    console.log('[BRIDGE-JS] getReminderState raw result:', JSON.stringify(raw))

    const { on, reminders: items } = raw
    console.log('[BRIDGE-JS] on=', on, 'reminders count=', items?.length ?? 0)

    setReminderOn(on)
    setReminders(items ?? [])
  }, [])

  // [DEBUG] log every time reminders state changes
  useEffect(() => {
    console.log('[STATE] reminders changed count=', reminders.length, JSON.stringify(reminders))
  }, [reminders])

  useEffect(() => {
    void syncReminderState()

    if (!Capacitor.isNativePlatform()) {
      return
    }

    let removeListener: (() => void) | undefined

    void CapacitorApp.addListener('appStateChange', ({ isActive }) => {
      if (isActive) {
        console.log('[APP] became active — syncing reminder state')
        void syncReminderState()
      }
    }).then((listener) => {
      removeListener = () => {
        void listener.remove()
      }
    })

    return () => {
      removeListener?.()
    }
  }, [syncReminderState])

  const toggleReminder = async () => {
    const next = !reminderOn
    setReminderOn(next)

    if (!next) {
      setReminders([])
    }

    if (Capacitor.isNativePlatform()) {
      await ReminderBridge.setReminderState({ on: next })
    }
  }

  const stateLabel = reminderOn ? 'ON' : 'OFF'

  return (
    <main className="app">
      <h1>La Suite</h1>

      <section className="reminder">
        <h2>Reminder</h2>

        <button
          type="button"
          className="toggle"
          onClick={() => {
            void toggleReminder()
          }}
          aria-pressed={reminderOn}
        >
          {stateLabel}
        </button>

        <p>Current state: {stateLabel}</p>

        {reminders.length > 0 && (
          <ul className="reminder-list">
            {reminders.map((item) => (
              <li key={item.id} className="reminder-item">
                <span className="reminder-text">{item.text}</span>
                <span className="reminder-date">
                  {new Date(item.date).toLocaleString()}
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  )
}

export default App
