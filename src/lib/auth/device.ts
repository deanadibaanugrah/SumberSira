// Ringkasan perangkat dari User-Agent, mis. "Chrome · Windows"
export function describeDevice(userAgent: string): string {
  if (/PostmanRuntime\//.test(userAgent)) return "Postman · API";
  const browser = /Edg\//.test(userAgent) ? "Edge" : /Chrome\//.test(userAgent) ? "Chrome" : /Firefox\//.test(userAgent) ? "Firefox" : /Safari\//.test(userAgent) ? "Safari" : "Browser";
  const os = /Windows/.test(userAgent) ? "Windows" : /Android/.test(userAgent) ? "Android" : /iPhone|iPad/.test(userAgent) ? "iOS" : /Mac OS/.test(userAgent) ? "macOS" : /Linux/.test(userAgent) ? "Linux" : "Perangkat lain";
  return `${browser} · ${os}`;
}