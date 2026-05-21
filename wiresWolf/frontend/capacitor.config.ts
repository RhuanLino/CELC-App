import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.wireswolfs.app',
  appName: 'WiresWolfs',
  webDir: 'dist',
  server: {
    cleartext: true,
    // Replace at build time with the host running the NestJS server.
    // The mobile app will load this URL when launched.
    url: 'https://1fdc-2804-1b2-1845-b29-4575-568c-cfa6-3ed6.ngrok-free.app',
  },
};

export default config;
