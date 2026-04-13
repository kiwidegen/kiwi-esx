import React from 'react'
import { FaGears } from "react-icons/fa6"

function VehicleHud({ data, config }) {
  const vehicle = data.vehicle
  const cfg = config.vehicle
  const colors = cfg.colors || {}

  const speed = vehicle.speed || 0
  const gear = vehicle.gear || 0
  const rpm = vehicle.rpm || 0
  const fuel = vehicle.fuel || 0
  const health = vehicle.health || 1000
  const seatbelt = vehicle.seatbelt || false
  const tractionLost = vehicle.traction_lost || false
  const engineOn = vehicle.engine_on || false

  // Check if aircraft (gear === -999 means hide gear)
  const isAircraft = gear === -999

  // Gear display (R, N, or number)
  let gearDisplay = gear
  if (gear === -1) gearDisplay = 'R'
  else if (gear === 0) gearDisplay = 'N'

  // RPM calculation (0-1 range from 0-8000 RPM)
  const maxRpm = 8000
  let rpmPercent = Math.min(1, rpm / maxRpm)

  // If engine is off, show 0 bars. If idling (low RPM), cap at 2 bars
  if (!engineOn) {
    rpmPercent = 0
  } else if (rpmPercent > 0 && rpmPercent < 0.25) {
    // Idle range (0-25% RPM) - cap at 2 bars
    rpmPercent = 0.067 // 2 out of 30 bars = 0.067
  }

  // Status indicators
  const fuelLow = fuel < (cfg.fuelBlinkAmountMinimum || 20)
  const engineDamaged = health < (cfg.engineLightHealthMinimum || 400)

  // Seatbelt logic: don't flash in aircraft, only flash when off in regular vehicles
  const seatbeltShouldFlash = isAircraft ? false : !seatbelt

  const rpmSegments = 30
  const activeSegments = Math.round(rpmPercent * rpmSegments)

  // Get position config with defaults
  const position = config.position?.vehicle || {}
  const statusGap = 3
  const speedGearGap = position.speedGearGap || 32

  return (
    <div
      style={{
        position: 'fixed',
        bottom: position.bottom || '20px',
        right: position.right || '20px',
        left: position.left,
        top: position.top,
        fontFamily: 'system-ui, -apple-system, sans-serif',
        userSelect: 'none'
      }}
    >
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'stretch', gap: 0 }}>
        {/* Speed and Gear */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: `3px` }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            {/* Gear box (hide for aircraft) */}
            {!isAircraft && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  padding: '6px 12px',
                  borderRadius: '4px',
                  backgroundColor: colors.statusBg || 'rgba(0, 0, 0, 0.7)',
                  marginTop: '2px'
                }}
              >
                <span
                  style={{
                    fontSize: '18px',
                    fontWeight: 700,
                    color: colors.gearText || '#ffffff',
                    lineHeight: 1
                  }}
                >
                  {gearDisplay}
                </span>
              </div>
            )}

            {/* Speed display */}
            <div style={{ display: 'flex', alignItems: 'baseline' }}>
              <span
                style={{
                  fontSize: '40px',
                  fontWeight: 700,
                  color: colors.speedText || '#ffffff',
                  letterSpacing: '-0.05em',
                  lineHeight: 1
                }}
              >
                {speed}
              </span>
              <span
                style={{
                  fontSize: '20px',
                  marginLeft: '4px',
                  fontWeight: 500,
                  color: colors.speedUnit || '#ffffff',
                  lineHeight: 1
                }}
              >
                KPH
              </span>
            </div>
          </div>
        </div>

        {/* RPM Bar - 20 vertical bars, yellow with last 3 red */}
        <div style={{ display: 'flex', gap: `${statusGap}px`, marginBottom: `6px` }}>
          {Array.from({ length: rpmSegments }).map((_, i) => {
            const isActive = i < activeSegments

            // Yellow for first segments, red for last 3
            const isRedZone = i >= rpmSegments - 3

            let bgColor = colors.rpmBarInactive || 'rgba(255, 255, 255, 0.25)'
            if (isActive) {
              bgColor = isRedZone ? '#ff0000' : '#ffff00'
            }

            return (
              <div
                key={i}
                style={{
                  width: '6px',
                  height: '40px',
                  borderRadius: '2px',
                  backgroundColor: bgColor,
                  transition: 'all 75ms ease'
                }}
              />
            )
          })}
        </div>

        {/* Status Indicators - Match RPM bar width and gap */}
        <div style={{ display: 'flex', gap: `${statusGap}px` }}>
          <StatusIndicator label="BELT" active={seatbelt} shouldFlash={seatbeltShouldFlash} isBinary={true} colors={colors} />
          <StatusIndicator label="FUEL" active={!fuelLow} shouldFlash={fuelLow} isBinary={false} percent={fuel} colors={colors} />
          <StatusIndicator label="ENGINE" active={!engineDamaged} shouldFlash={engineDamaged} isBinary={false} percent={Math.round((health / 1000) * 100)} colors={colors} />
          <StatusIndicator label="TC" active={!tractionLost} shouldFlash={tractionLost} isBinary={true} colors={colors} />
        </div>
      </div>
    </div>
  )
}

function StatusIndicator({ label, active, shouldFlash, isBinary, percent, colors }) {
  // Determine color: red if warning/inactive, green if active and no warning
  const barColor = (shouldFlash || !active) ? (colors.statusBad || '#ff3333') : (colors.statusGood || '#22aa22')

  // For binary indicators (belt, TC), simple on/off
  if (isBinary) {
    const showBar = active || shouldFlash
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          padding: '4px 8px',
          borderRadius: '4px',
          backgroundColor: colors.statusBg || 'rgba(0, 0, 0, 0.7)',
          flex: 1
        }}
      >
        <span
          style={{
            fontSize: '11px',
            fontWeight: 700,
            letterSpacing: '0.05em',
            color: colors.statusText || 'rgba(255, 255, 255, 0.9)'
          }}
        >
          {label}
        </span>
        <div
          style={{
            width: '100%',
            height: '6px',
            borderRadius: '9999px',
            marginTop: '4px',
            backgroundColor: showBar ? barColor : (colors.statusInactive || '#333'),
            transition: 'all 200ms ease',
            animation: shouldFlash ? 'flash 1s ease-in-out infinite' : 'none'
          }}
        />
        <style>
          {`
            @keyframes flash {
              0%, 100% { opacity: 1; }
              50% { opacity: 0.3; }
            }
          `}
        </style>
      </div>
    )
  }

  // For percentage indicators (fuel, engine), fill right to left
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '4px 8px',
        borderRadius: '4px',
        backgroundColor: colors.statusBg || 'rgba(0, 0, 0, 0.7)',
        flex: 1
      }}
    >
      <span
        style={{
          fontSize: '11px',
          fontWeight: 700,
          letterSpacing: '0.05em',
          color: colors.statusText || 'rgba(255, 255, 255, 0.9)'
        }}
      >
        {label}
      </span>
      <div
        style={{
          width: '100%',
          height: '6px',
          borderRadius: '9999px',
          marginTop: '4px',
          backgroundColor: colors.statusInactive || '#333',
          position: 'relative',
          overflow: 'hidden'
        }}
      >
        <div
          style={{
            position: 'absolute',
            left: 0,
            top: 0,
            height: '100%',
            width: `${percent}%`,
            backgroundColor: barColor,
            borderRadius: '9999px',
            transition: 'all 200ms ease',
            animation: shouldFlash ? 'flash 1s ease-in-out infinite' : 'none'
          }}
        />
      </div>
      <style>
        {`
          @keyframes flash {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
          }
        `}
      </style>
    </div>
  )
}

export default VehicleHud
