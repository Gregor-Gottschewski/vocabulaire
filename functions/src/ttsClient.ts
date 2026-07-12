import * as textToSpeech from "@google-cloud/text-to-speech";
import ffmpegPath from "@ffmpeg-installer/ffmpeg";
import ffmpeg from "fluent-ffmpeg";
import { PassThrough } from "node:stream";

ffmpeg.setFfmpegPath(ffmpegPath.path);

// Uses Application Default Credentials of the Cloud Functions runtime
// service account — no exportable API key/credential exists anywhere.
const client = new textToSpeech.TextToSpeechClient();

export interface SynthesisResult {
  audioContent: Buffer;
  mimeType: string;
}

export async function synthesize(text: string): Promise<SynthesisResult> {
  const [response] = await client.synthesizeSpeech({
    input: { text },
    voice: { languageCode: "fr-FR", name: "fr-FR-Standard-C" },
    audioConfig: {
      audioEncoding: "LINEAR16",
      sampleRateHertz: 16000,
    },
  });

  const wavBuffer = Buffer.from(response.audioContent as Uint8Array);
  const audioContent = await transcodeWavToAacM4a(wavBuffer);

  return { audioContent, mimeType: "audio/mp4" };
}

/**
 * Transcodes WAV/PCM to AAC-LC in an MP4 (.m4a) container, matching the
 */
function transcodeWavToAacM4a(wavBuffer: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const input = new PassThrough();
    input.end(wavBuffer);

    const chunks: Buffer[] = [];
    const output = new PassThrough();
    output.on("data", (chunk) => chunks.push(chunk));
    output.on("end", () => resolve(Buffer.concat(chunks)));
    output.on("error", reject);

    ffmpeg(input)
      .audioCodec("aac")
      .audioBitrate("16k")
      .audioChannels(1)
      .audioFrequency(16000)
      .format("mp4")
      .outputOptions(["-movflags", "frag_keyframe+empty_moov"])
      .on("error", reject)
      .pipe(output, { end: true });
  });
}
