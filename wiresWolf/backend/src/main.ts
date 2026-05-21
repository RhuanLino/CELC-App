import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import * as os from 'os';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
  const port = Number(process.env.PORT) || 8080;
  await app.listen(port, '0.0.0.0');

  const ips = Object.values(os.networkInterfaces())
    .flat()
    .filter((i) => i && i.family === 'IPv4' && !i.internal)
    .map((i) => i!.address);

  console.log(`\n=== WiresWolfs Server ===`);
  console.log(`Local:    http://localhost:${port}`);
  ips.forEach((ip) => console.log(`Network:  http://${ip}:${port}`));
  console.log(`=========================\n`);
}
bootstrap();
