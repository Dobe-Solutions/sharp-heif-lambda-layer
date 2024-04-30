import sharp from 'sharp';

await sharp('sample.heif').toFile('output-heif.jpg');
await sharp('sample.avif').toFile('output-avif.jpg');

console.log('sharp test successful');