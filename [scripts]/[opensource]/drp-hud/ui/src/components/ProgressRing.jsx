import React from "react";

function ProgressRing({
  progress = 0,
  background = "#a6a6a638",
  gradientStart = "#ffffff",
  gradientEnd = "#ffffff",
  id = "gradient",
}) {
  const reduction = 0.25;
  const strokeWidth = 25;
  const viewBox = 200;
  const center = viewBox / 2;
  const radius = center - strokeWidth / 2 - 8;
  const circumference = 2 * Math.PI * radius;
  const startAngle = 90 + 180 * reduction;
  const progressOffset = (circumference * (100 - progress * (1 - reduction))) / 100;
  const gradientId = `gradient-${id}-${Math.random().toString(36).substr(2, 9)}`;

  return (
    <div className="progress-ring-wrapper">
      <svg viewBox={`0 0 ${viewBox} ${viewBox}`} className="progress-ring-svg">
        <defs>
          <linearGradient id={gradientId} x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor={gradientStart} />
            <stop offset="100%" stopColor={gradientEnd} />
          </linearGradient>
        </defs>

        <circle
          transform={`rotate(${startAngle} ${center} ${center})`}
          cx={center}
          cy={center}
          r={radius}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={circumference * reduction}
          fill="none"
          stroke={background}
          strokeLinecap="round"
        />

        <circle
          transform={`rotate(${startAngle} ${center} ${center})`}
          cx={center}
          cy={center}
          r={radius}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={progressOffset}
          fill="none"
          stroke={`url(#${gradientId})`}
          strokeLinecap="round"
        />
      </svg>
    </div>
  );
}

export default ProgressRing;
