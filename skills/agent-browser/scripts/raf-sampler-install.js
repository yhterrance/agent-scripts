// rAF stack-trace sampler. Pipe into `agent-browser eval --stdin`.
// Wraps requestAnimationFrame and captures a stack trace from every Nth call
// (default every 20th, capped at 500 samples). Pair with raf-sampler-analyze.js
// to bucket samples by call-site fingerprint.
//
// Typical use: cpu-probe.js shows rafPerSec >> 60 at idle. Install this sampler,
// wait ~10 s, run the analyzer to find which code is calling rAF.
(() => {
  if (window.__rafSampler) {
    window.__rafSampler.samples = [];
    window.__rafSampler.counter = 0;
    return 'reset';
  }
  const samples = [];
  const sampleEvery = 20;
  let counter = 0;
  const orig = window.requestAnimationFrame;
  window.requestAnimationFrame = function (cb) {
    counter++;
    window.__rafSampler.counter = counter;
    if (counter % sampleEvery === 0 && samples.length < 500) {
      try { samples.push(new Error().stack || ''); } catch (e) {}
    }
    return orig.call(this, cb);
  };
  window.__rafSampler = { samples, counter, sampleEvery };
  return 'installed sampleEvery=' + sampleEvery;
})();
