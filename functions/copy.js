// Push text per language. Anything other than "fil" falls back to English
// (covers users who never saved a language).
const STATUS_COPY = {
  accepted: {
    en: {title: "Report accepted", body: "A responder has accepted your report."},
    fil: {title: "Tinanggap ang report", body: "Tinanggap ng isang responder ang iyong report."},
  },
  dispatched: {
    en: {title: "Help is on the way", body: "A responder has been dispatched to your location."},
    fil: {title: "Papunta na ang tulong", body: "May responder nang ipinadala sa iyong lokasyon."},
  },
  onScene: {
    en: {title: "Responder on scene", body: "A responder has arrived at your location."},
    fil: {title: "Nasa lugar na ang responder", body: "Dumating na ang responder sa iyong lokasyon."},
  },
  resolved: {
    en: {title: "Report resolved", body: "Your report has been marked as resolved."},
    fil: {title: "Nalutas na ang report", body: "Nalutas na ang iyong report."},
  },
  pending: {
    en: {title: "Report reopened", body: "Your report is back in the queue for review."},
    fil: {title: "Muling binuksan ang report", body: "Bumalik sa pila ang iyong report para sa pagsusuri."},
  },
};

const ASSIGNED_COPY = {
  en: {title: "New case assigned", body: "You have been assigned a new report. Open the app to view it."},
  fil: {title: "May bagong case na itinalaga", body: "May bagong report na itinalaga sa iyo. Buksan ang app para makita ito."},
};

// Prefixed to the user's status push so they can tell which service it is about.
const SERVICE_LABEL = {
  medical: {en: "Medical", fil: "Medikal"},
  police: {en: "Police", fil: "Pulis"},
  fire: {en: "Fire", fil: "Bumbero"},
};

const pickLang = (doc) => (doc?.languageCode === "fil" ? "fil" : "en");

module.exports = {STATUS_COPY, ASSIGNED_COPY, SERVICE_LABEL, pickLang};
