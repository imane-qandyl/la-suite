import { App as CapacitorApp } from '@capacitor/app'
import { Capacitor } from '@capacitor/core'
import { useCallback, useEffect, useState } from 'react'
import { ReminderBridge } from './reminderBridge'
import './App.css'

function App() {
  const [reminderOn, setReminderOn] = useState(false)
  const [reminderText, setReminderText] = useState<string | null>(null)
  const [reminderDate, setReminderDate] = useState<string | null>(null)

  const syncReminderState = useCallback(async () => {
    if (!Capacitor.isNativePlatform()) {
      return
    }

    const { on, text, date } = await ReminderBridge.getReminderState()
    setReminderOn(on)
    setReminderText(text ?? null)
    setReminderDate(date ?? null)
  }, [])

  useEffect(() => {
    void syncReminderState()

    if (!Capacitor.isNativePlatform()) {
      return
    }

    let removeListener: (() => void) | undefined

    void CapacitorApp.addListener('appStateChange', ({ isActive }) => {
      if (isActive) {
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
      setReminderText(null)
      setReminderDate(null)
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

        {reminderOn && reminderText ? (
          <p>Reminder: {reminderText}</p>
        ) : null}

        {reminderOn && reminderDate ? (
          <p>Scheduled: {new Date(reminderDate).toLocaleString()}</p>
        ) : null}
      </section>
    </main>
  )
}

export default App
