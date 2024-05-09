import sharp from 'sharp';

await sharp('sample.heic').toFile('output-heic.jpg');
await sharp('sample.avif').toFile('output-avif.jpg');

if(process.env.BUILD_HEVC_ENCODER === '1') 
    await sharp('output-heic.jpg').heif({ compression: 'hevc' }).toFile('output-jpg.heic');

if(process.env.BUILD_AV1_ENCODER === '1')
    await sharp('output-avif.jpg').heif({ compression: 'av1' }).toFile('output-jpg.avif');

console.log('sharp test successful');