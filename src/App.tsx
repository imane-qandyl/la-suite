import { useState } from 'react'
import './App.css'

function App() {
  const [reminderOn, setReminderOn] = useState(false)

  const toggleReminder = () => {
    setReminderOn((current) => !current)
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
          onClick={toggleReminder}
          aria-pressed={reminderOn}
        >
          {stateLabel}
        </button>

        <p>Current state: {stateLabel}</p>
      </section>
    </main>
  )
}

export default App
