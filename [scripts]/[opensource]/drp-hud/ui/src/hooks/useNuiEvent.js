import { useEffect, useRef } from "react";

export function useNuiEvent(event, callback) {
  const callbackRef = useRef(callback);

  useEffect(() => {
    callbackRef.current = callback;
  }, [callback]);

  useEffect(() => {
    const handler = (e) => {
      if (e.data.type === event) {
        callbackRef.current(e.data.payload);
      }
    };

    window.addEventListener("message", handler);
    return () => window.removeEventListener("message", handler);
  }, [event]);
}

export function fetchNui(event, data = {}) {
  const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : "drp-hud";

  return fetch(`https://${resourceName}/${event}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  })
    .then((res) => res.json())
    .catch(() => null);
}
