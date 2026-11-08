const PH_OFFSET_MS = 8 * 60 * 60 * 1000; // Philippines is UTC+8, no daylight saving

function isMinor(ms) {
  if (!ms) return false;
  // Shift both dates to Philippine time, then read them with the UTC getters.
  const dob = new Date(ms + PH_OFFSET_MS);
  const now = new Date(Date.now() + PH_OFFSET_MS);
  let age = now.getUTCFullYear() - dob.getUTCFullYear();
  const m = now.getUTCMonth() - dob.getUTCMonth();
  if (m < 0 || (m === 0 && now.getUTCDate() < dob.getUTCDate())) age--;
  return age < 18;
}

module.exports = {isMinor};
