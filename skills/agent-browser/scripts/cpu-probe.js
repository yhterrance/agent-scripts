// agent-browser --init-script probe.
// Counts rAF, setInterval, setTimeout; tracks active timer ids; observes long tasks.
// After install, sample with: agent-browser eval "JSON.stringify(window.__cpuProbeRate)"
(() => {
  if (window.__cpuProbe) return;
  window.__cpuProbe = {
    raf: 0,
    timeouts: 0,
    intervals: 0,
    activeIntervals: new Set(),
    activeTimeouts: new Set(),
    longTasks: [],
  };

  const origRAF = window.requestAnimationFrame;
  window.requestAnimationFrame = (cb) => {
    window.__cpuProbe.raf++;
    return origRAF(cb);
  };

  const origSI = window.setInterval;
  window.setInterval = function (...a) {
    const id = origSI.apply(this, a);
    window.__cpuProbe.intervals++;
    window.__cpuProbe.activeIntervals.add(id);
    return id;
  };
  const origCI = window.clearInterval;
  window.clearInterval = function (id) {
    window.__cpuProbe.activeIntervals.delete(id);
    return origCI.call(this, id);
  };

  const origST = window.setTimeout;
  window.setTimeout = function (...a) {
    const id = origST.apply(this, a);
    window.__cpuProbe.timeouts++;
    window.__cpuProbe.activeTimeouts.add(id);
    return id;
  };
  const origCT = window.clearTimeout;
  window.clearTimeout = function (id) {
    window.__cpuProbe.activeTimeouts.delete(id);
    return origCT.call(this, id);
  };

  try {
    const po = new PerformanceObserver((list) => {
      for (const e of list.getEntries()) {
        window.__cpuProbe.longTasks.push({ start: e.startTime, dur: e.duration });
        if (window.__cpuProbe.longTasks.length > 500) window.__cpuProbe.longTasks.shift();
      }
    });
    po.observe({ entryTypes: ['longtask'] });
  } catch (e) {}

  let last = { raf: 0, t: performance.now(), lt: 0 };
  setInterval(() => {
    const now = performance.now();
    const dt = (now - last.t) / 1000;
    const lt = window.__cpuProbe.longTasks.length;
    window.__cpuProbeRate = {
      rafPerSec: +((window.__cpuProbe.raf - last.raf) / dt).toFixed(1),
      longTasksPerSec: +((lt - last.lt) / dt).toFixed(1),
      activeIntervals: window.__cpuProbe.activeIntervals.size,
      activeTimeouts: window.__cpuProbe.activeTimeouts.size,
      totalRAF: window.__cpuProbe.raf,
      totalIntervalsCreated: window.__cpuProbe.intervals,
      totalTimeoutsCreated: window.__cpuProbe.timeouts,
    };
    last = { raf: window.__cpuProbe.raf, t: now, lt };
  }, 1000);

  console.log('[cpu-probe] installed');
})();
