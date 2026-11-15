import { copyFileSync, cpSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const project = fileURLToPath(new URL("./", import.meta.url));
const output = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";
mkdirSync(output, { recursive: true });

for (const file of ["game.rbxl", "PLAY.json"]) {
    copyFileSync(join(project, file), join(output, file));
}
for (const directory of ["src", "screenshots"]) {
    cpSync(join(project, directory), join(output, directory), { recursive: true });
}

const dossier = buildDossier(output, {
    text_max_bytes: 65_536,
    max_instances: 500_000,
    scripts_max_source_bytes: 8_388_608,
    scripts_max_path_chars: 1_048_576,
    screenshots: { max: 4, max_bytes: 262_144 },
});
writeFileSync(join(output, "dossier.json"), dossier);
