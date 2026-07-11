import sharp from 'sharp';
import { mkdirSync } from 'fs';

mkdirSync('public', { recursive: true });

const makeIcon = (size) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}">
  <rect width="${size}" height="${size}" rx="${size * 0.17}" fill="#111111"/>
  <rect width="${size}" height="${size}" rx="${size * 0.17}" fill="url(#g)"/>
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#6366f1"/>
      <stop offset="100%" stop-color="#8b5cf6"/>
    </linearGradient>
  </defs>
  <text x="${size / 2}" y="${size * 0.72}" font-family="Arial Black, Arial" font-size="${size * 0.55}" font-weight="900" fill="white" text-anchor="middle">W</text>
</svg>`;

await sharp(Buffer.from(makeIcon(192))).png().toFile('public/icon-192.png');
await sharp(Buffer.from(makeIcon(512))).png().toFile('public/icon-512.png');
console.log('Icons erstellt!');
