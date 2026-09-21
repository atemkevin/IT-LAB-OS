import { ImageResponse } from 'next/og'

export const runtime = "nodejs";
export const size = { width: 512, height: 512 }
export const contentType = 'image/png'

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#0d0f14',
          borderRadius: '128px',
          color: 'white',
          fontSize: 280,
          fontWeight: 800,
          fontFamily: 'sans-serif',
        }}
      >
        L
      </div>
    ),
    { ...size }
  )
}
