// Remotion config for the FE for Raccoons explainer video.
// Render: npm run video:render  ·  Edit live: npm run video:studio
import { Config } from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');
Config.setEntryPoint('./video/index.jsx');
Config.setOutputLocation('./out/explainer.mp4');
