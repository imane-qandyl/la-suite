import { App as CapacitorApp } from '@capacitor/app'
import { Capacitor } from '@capacitor/core'
import { useCallback, useEffect, useState } from 'react'
import { type ReminderItem, ReminderBridge } from './reminderBridge'
import './App.css'

// ── Helpers ─────────────────────────────────────────────────────────────────

function formatReminderDate(iso: string): string {
  const date = new Date(iso)
  const today    = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)

  const isSameDay = (a: Date, b: Date) =>
    a.getDate()    === b.getDate()    &&
    a.getMonth()   === b.getMonth()   &&
    a.getFullYear() === b.getFullYear()

  const timeStr = date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })

  if (isSameDay(date, today))    return `Aujourd'hui · ${timeStr}`
  if (isSameDay(date, tomorrow)) return `Demain · ${timeStr}`

  return date.toLocaleDateString('fr-FR', {
    weekday: 'long',
    day:     'numeric',
    month:   'long',
  }) + ` · ${timeStr}`
}

// ── Component ────────────────────────────────────────────────────────────────

function App() {
  // ── State (unchanged) ──
  const [reminderOn, setReminderOn] = useState(false)
  const [reminders, setReminders]   = useState<ReminderItem[]>([])

  // ── Bridge sync (unchanged) ──
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

  // ── Toggle (unchanged) ──
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

  // ── Derived ──
  const count      = reminders.length
  const countLabel = count === 0
    ? 'Aucun rappel actif'
    : count === 1
      ? '1 rappel actif'
      : `${count} rappels actifs`

  return (
    <div className="app">

      {/* ── En-tête ── */}
      <header className="header" role="banner">
        <div className="header__logo-row">
          <div className="header__badge" aria-hidden="true">
            <div className="header__badge-inner" />
          </div>
          <h1 className="header__title">La Suite</h1>
        </div>
        <p className="header__subtitle">Votre espace numérique</p>
      </header>

      {/* ── Contenu principal ── */}
      <main className="main-content">

        {/* ── Carte statut ── */}
        <section className="card" aria-labelledby="status-heading">
          <div className="card__header">
            <h2 className="card__title" id="status-heading">Rappels actifs</h2>
          </div>
          <div className="card__body">
            <div className="status-row">
              <span className="status-label">
                {reminderOn ? 'Les rappels Siri sont activés.' : 'Les rappels Siri sont désactivés.'}
              </span>
              <button
                type="button"
                className={`toggle ${reminderOn ? 'toggle--on' : 'toggle--off'}`}
                onClick={() => { void toggleReminder() }}
                aria-pressed={reminderOn}
                aria-label={reminderOn ? 'Désactiver les rappels' : 'Activer les rappels'}
              >
                <span className="toggle__dot" aria-hidden="true" />
                {reminderOn ? 'Actif' : 'Inactif'}
              </button>
            </div>
            <p className="status-hint">
              Les rappels créés avec Siri sont enregistrés automatiquement dans La Suite.
            </p>
          </div>
        </section>

        {/* ── Carte rappels ── */}
        <section className="card" aria-labelledby="reminders-heading">
          <div className="card__header">
            <div className="reminders-meta">
              <h2 className="card__title" id="reminders-heading">Mes rappels</h2>
              {count > 0 && (
                <span className="reminders-count" aria-live="polite">
                  <span className="reminders-count__dot" aria-hidden="true" />
                  {countLabel}
                </span>
              )}
            </div>
          </div>

          {count === 0 ? (
            <div className="empty-state" role="status">
              <span className="empty-state__icon" aria-hidden="true">🗒</span>
              <p className="empty-state__title">Aucun rappel</p>
              <p className="empty-state__body">
                Les rappels créés avec Siri apparaîtront ici.
              </p>
            </div>
          ) : (
            <ul className="reminder-list" aria-label="Liste des rappels">
              {reminders.map((item) => (
                <li key={item.id} className="reminder-item">
                  <span className="reminder-item__indicator" aria-hidden="true" />
                  <div className="reminder-item__body">
                    <span className="reminder-item__text">{item.text}</span>
                    <span className="reminder-item__date">
                      {formatReminderDate(item.date)}
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>

      </main>

      {/* ── Pied de page ── */}
      <footer className="footer">
        <p className="footer__text">
          La Suite — Service public numérique
        </p>
      </footer>

    </div>
  )
}

export default App
