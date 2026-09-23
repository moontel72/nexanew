// WHEP test page logic — proves the WebRTC viewing path end to end.
//
// Loaded by web/whep-test.html (served at https://cricket.traceodd.com/whep-test.html).
// It asks the public API for the match's WHEP target, then plays it with the
// same vendored client the public screen will use (vendor/whep.js), so a green
// result here means the player integration is just plumbing.
//
// The page shows its own clock: put a clock/stopwatch in front of the camera
// and the difference is the real glass-to-glass delay, with no guesswork.
(function () {
  "use strict";

  // The fixture the owner tests with, so the page works with no query string.
  var DEFAULT_MATCH = "a2c0880f-cc5b-40d9-8d5c-6ffa3916e021";

  var video = document.getElementById("video");
  var statusEl = document.getElementById("status");
  var logEl = document.getElementById("log");
  var clockEl = document.getElementById("clock");
  var framesEl = document.getElementById("frames");
  var wireEl = document.getElementById("wire");

  var session = null;

  function query(name) {
    var params = new URLSearchParams(window.location.search);
    return params.get(name);
  }

  function setStatus(text, kind) {
    statusEl.textContent = text;
    statusEl.className = "status " + (kind || "");
  }

  function log(message) {
    var line = new Date().toISOString().slice(11, 19) + "  " + message;
    logEl.textContent += line + "\n";
    if (window.console) {
      console.log(line);
    }
  }

  function loadScript(src) {
    if (window.ToddWhep) {
      return Promise.resolve();
    }

    return new Promise(function (resolve, reject) {
      var existing = document.querySelector('script[data-src="' + src + '"]');
      if (existing) {
        existing.addEventListener("load", function () {
          resolve();
        });
        existing.addEventListener("error", function () {
          reject(new Error("failed to load " + src));
        });
        return;
      }

      var script = document.createElement("script");
      script.src = src;
      script.async = false;
      script.setAttribute("data-src", src);
      script.onload = function () {
        resolve();
      };
      script.onerror = function () {
        reject(new Error("failed to load " + src));
      };
      document.head.appendChild(script);
    });
  }

  function fetchJson(path) {
    return fetch(path, { headers: { Accept: "application/json" } }).then(function (response) {
      if (!response.ok) {
        throw new Error(path + " -> HTTP " + response.status);
      }
      return response.json();
    });
  }

  function describeWire(whep) {
    if (!whep) {
      return "no whep block";
    }
    return (
      "url=" +
      whep.url +
      " camera=" +
      whep.camera_id +
      " ice=" +
      ((whep.ice_servers && whep.ice_servers.length) || 0) +
      " server(s)"
    );
  }

  function startClock() {
    setInterval(function () {
      clockEl.textContent = new Date().toLocaleTimeString();
      framesEl.textContent = video.videoWidth
        ? video.videoWidth + "x" + video.videoHeight + " decoded"
        : "no decoded frames yet";
    }, 1000);
  }

  function start() {
    var match = query("match") || DEFAULT_MATCH;
    var path = "/api/v1/cricket/public/matches/" + encodeURIComponent(match) + "/stream";

    startClock();
    setStatus("asking the API…");
    log("match=" + match);
    log("GET " + path);

    return fetchJson(path)
      .then(function (info) {
        log("stream payload: " + JSON.stringify(info));
        wireEl.textContent = describeWire(info && info.whep);

        var whep = info && info.whep;
        if (!whep || !whep.url || !whep.token) {
          // Say *why* instead of a bare failure: the API only returns a WHEP
          // target when a live broadcaster camera is on air.
          setStatus(
            "No WHEP target — nothing live for this match (available=" +
              (info && info.available) +
              "). Start the broadcaster + Todd Studio, then reload.",
            "bad"
          );
          return undefined;
        }

        log("WHEP target: " + whep.url + " (room " + whep.room_id + ", camera " + whep.camera_id + ")");

        return loadScript("/vendor/whep.js").then(function () {
          if (!window.ToddWhep) {
            setStatus("vendor/whep.js loaded but did not define ToddWhep", "bad");
            return undefined;
          }

          setStatus("WHEP: connecting…", "warn");
          session = window.ToddWhep.watch({
            url: whep.url,
            token: whep.token,
            video: video,
            iceServers: whep.ice_servers || [],
            onState: function (state, detail) {
              log("state=" + state + (detail ? " (" + detail + ")" : ""));
              if (state === "watching") {
                setStatus("WHEP: watching — compare the clock below with a clock in the camera", "ok");
              } else if (state === "failed") {
                setStatus("WHEP: failed — " + detail, "bad");
              } else {
                setStatus("WHEP: " + state + (detail ? " — " + detail : ""), "warn");
              }
            },
          });
          return undefined;
        });
      })
      .catch(function (error) {
        setStatus("FAILED: " + (error && error.message ? error.message : error), "bad");
        log("error: " + (error && error.stack ? error.stack : error));
      });
  }

  document.getElementById("restart").addEventListener("click", function () {
    if (session) {
      session.close();
      session = null;
    }
    video.srcObject = null;
    logEl.textContent = "";
    start();
  });

  window.addEventListener("pagehide", function () {
    if (session) {
      session.close();
    }
  });

  start();
})();
