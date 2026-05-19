// Pair with raf-sampler-install.js. Pipe into `agent-browser eval --stdin`.
// Buckets the captured stack traces by call-site fingerprint (top 4 non-trivial
// frames) and reports top 8 buckets. Each bucket count multiplied by sampleEvery
// gives the approximate rAF call volume from that call site.
(() => {
  if (!window.__rafSampler) return 'no sampler installed';
  const samples = window.__rafSampler.samples;
  // Drop the leading "Error" line and frames pointing at the sampler wrapper itself,
  // then take the top 4 remaining frames as the fingerprint.
  const fingerprint = (stack) => {
    const lines = stack.split('\n').map((l) => l.trim()).filter(Boolean);
    const filtered = lines
      .filter((l) => !l.startsWith('Error'))
      .filter((l) => !/__rafSampler|requestAnimationFrame.*\(<anonymous>/.test(l));
    return filtered.slice(0, 4).join(' <- ');
  };

  const counts = {};
  for (const s of samples) {
    const fp = fingerprint(s);
    counts[fp] = (counts[fp] || 0) + 1;
  }

  const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]);
  return JSON.stringify(
    {
      totalSamples: samples.length,
      sampleEvery: window.__rafSampler.sampleEvery,
      approxRAFsCovered: samples.length * window.__rafSampler.sampleEvery,
      uniqueBuckets: sorted.length,
      top: sorted.slice(0, 8).map(([fp, n]) => ({ count: n, frames: fp })),
    },
    null,
    2,
  );
})();
