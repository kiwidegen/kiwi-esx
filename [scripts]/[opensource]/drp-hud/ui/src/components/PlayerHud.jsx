import React from "react";
import ProgressRing from "./ProgressRing";
import {
  BsMicFill,
  BsMicMuteFill,
  BsHeartPulseFill,
  BsShieldFill,
  BsFillLightningChargeFill,
} from "react-icons/bs";
import { FaLungs, FaRunning } from "react-icons/fa";
import { FaBurger } from "react-icons/fa6";
import { RiDrinks2Fill } from "react-icons/ri";

function PlayerHud({ data, config, alignment }) {
  const player = data.player;
  const cfg = config.player;

  const healthPercent = player.is_dead ? 0 : Math.max(0, player.health);

  // Hardcoded position: 5px from bottom, centered
  const hudStyle = {
    left: '50%',
    bottom: '5px',
    transform: "translateX(-50%)",
  };

  return (
    <div className="hud-container" style={hudStyle}>
      <div className="hud-items">
        <HudItem
          IconComponent={data.isTalking ? BsMicFill : BsMicMuteFill}
          value={data.voice}
          config={{
            icon: data.isTalking || data.isTalkingOnRadio ? cfg.voice.icon_talking : cfg.voice.icon_not_talking,
            bar_background: cfg.voice.bar_background,
            bar_gradient_start: cfg.voice.bar_gradient_start,
            bar_gradient_end: cfg.voice.bar_gradient_end,
          }}
          id="voice"
        />

        <HudItem
          IconComponent={BsHeartPulseFill}
          value={healthPercent}
          config={cfg.health}
          id="health"
        />

        {player.armor > 0 && (
          <HudItem
            IconComponent={BsShieldFill}
            value={player.armor}
            config={cfg.armor}
            id="armor"
          />
        )}

        <HudItem IconComponent={FaBurger} value={player.hunger} config={cfg.hunger} id="hunger" />

        <HudItem
          IconComponent={RiDrinks2Fill}
          value={player.thirst}
          config={cfg.thirst}
          id="thirst"
        />

        {player.stamina > 0 && player.stamina < 100 && (
          <HudItem
            IconComponent={FaRunning}
            value={player.stamina}
            config={cfg.stamina}
            id="stamina"
          />
        )}

        {player.oxygen < 100 && (
          <HudItem IconComponent={FaLungs} value={player.oxygen} config={cfg.oxygen} id="oxygen" />
        )}

        {player.junglejuice > 0 && player.junglejuice < 100 && (
          <HudItem
            IconComponent={BsFillLightningChargeFill}
            value={player.junglejuice}
            config={cfg.junglejuice}
            id="junglejuice"
          />
        )}
      </div>
    </div>
  );
}

function HudItem({ IconComponent, value, config, id }) {
  if (!config) {
    return null;
  }

  return (
    <div className="item_container">
      <IconComponent className="relationIcon" style={{ color: config.icon }} />
      <ProgressRing
        progress={value}
        background={config.bar_background}
        gradientStart={config.bar_gradient_start}
        gradientEnd={config.bar_gradient_end}
        id={id}
      />
    </div>
  );
}

export default PlayerHud;
