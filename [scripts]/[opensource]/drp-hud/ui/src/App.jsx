import React, { useState, useEffect } from "react";
import { useNuiEvent } from "./hooks/useNuiEvent";
import PlayerHud from "./components/PlayerHud";
import VehicleHud from "./components/VehicleHud";

const defaultConfig = {
  vehicle: {
    useCircleHud: false,
    metricText: "KM/h",
    engineLightHealthMinimum: 300,
    fuelBlinkAmountMinimum: 25,
    barColor: { r: 245, g: 203, b: 66 },
    barThreshhold: 8000,
    barAmount: 30,
    emptyBarColor: "rgba(128, 128, 128, 0.658)",
  },
  player: {
    health: {
      icon: "#db1212",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#db1212",
      bar_gradient_end: "#b50d0d",
    },
    armor: {
      icon: "#7dbee3",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#7dbee3",
      bar_gradient_end: "#1096e3",
    },
    hunger: {
      icon: "#e69160",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#e69160",
      bar_gradient_end: "#e85b09",
    },
    thirst: {
      icon: "#09d8eb",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#09d8eb",
      bar_gradient_end: "#4ea8cf",
    },
    stamina: {
      icon: "#c7c7c7",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#c2c2c2",
      bar_gradient_end: "#c7c7c7",
    },
    oxygen: {
      icon: "#24a2e0",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#03a9fc",
      bar_gradient_end: "#24a2e0",
    },
    voice: {
      icon_talking: "#77e339",
      icon_not_talking: "#ffffff",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#77e339",
      bar_gradient_end: "#0ee341",
    },
    junglejuice: {
      icon: "#c79d6f",
      bar_background: "rgba(255, 255, 255, 0.25)",
      bar_gradient_start: "#c79d6f",
      bar_gradient_end: "#c79d6f",
    },
  },
};

function App() {
  const [data, setData] = useState(null);
  const [config, setConfig] = useState(defaultConfig);
  const [visible, setVisible] = useState(false);
  const [opacity, setOpacity] = useState(1);

  // Listen for show/hide actions
  useNuiEvent("show", () => {
    setVisible(true);
    setOpacity(1);
  });

  useNuiEvent("hide", (payload) => {
    if (payload && payload.opacity !== undefined) {
      setOpacity(payload.opacity);
    } else {
      setVisible(false);
      setOpacity(0);
    }
  });

  // Listen for full state updates
  useNuiEvent("hud.data", (payload) => {
    setData(payload);
    // Update config if sent from Lua
    if (payload.config) {
      setConfig(payload.config);
    }
  });

  // Listen for delta updates (single value changes)
  useNuiEvent("hud.update", (payload) => {
    if (!data) return;

    const { category, key, value } = payload;

    setData((prevData) => {
      if (!prevData) return prevData;

      // Handle nested updates (player.health, vehicle.speed, etc)
      if (category === "player" || category === "vehicle") {
        // Special case: voice needs to be updated at root level too
        if (category === "player" && key === "voice") {
          return {
            ...prevData,
            voice: value, // Update root level
            [category]: {
              ...prevData[category],
              [key]: value,
            },
          };
        }

        return {
          ...prevData,
          [category]: {
            ...prevData[category],
            [key]: value,
          },
        };
      } else if (category === "ui") {
        // UI category updates (hide, inVehicle, etc)
        return {
          ...prevData,
          [key]: value,
        };
      }

      return prevData;
    });
  });

  // Request initial data on mount
  useEffect(() => {
    fetch(`https://${GetParentResourceName()}/hud.data`, {
      method: "POST",
      body: JSON.stringify({}),
    }).catch(() => {});

    // Send ready callback
    setTimeout(() => {
      fetch(`https://${GetParentResourceName()}/ready`, {
        method: "POST",
        body: JSON.stringify({ show: true }),
      }).catch(() => {});
    }, 100);
  }, []);

  // Don't render if no data, hidden, or not visible
  if (!data || data.hide || !visible) return null;

  const alignment = data.alignment || { x: 190, y: 900, size: 100 };

  return (
    <div style={{ opacity: opacity, transition: "opacity 0.3s ease" }}>
      {data.inVehicle && <VehicleHud data={data} config={config} />}

      {!data.hide_icons && <PlayerHud data={data} config={config} alignment={alignment} />}
    </div>
  );
}

function GetParentResourceName() {
  return window.GetParentResourceName ? window.GetParentResourceName() : "drp-hud";
}

export default App;
