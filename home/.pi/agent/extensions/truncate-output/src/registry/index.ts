import { ResolvedConfig } from "../config.js";
import { FilterRegistry } from "../filter-engine.js";
import { fileRules } from "./files.js";
import { networkRules } from "./network.js";
import { searchRules } from "./search.js";

const builtInRules = [...fileRules, ...networkRules, ...searchRules];

export function createRegistry(config?: ResolvedConfig): FilterRegistry {
  const resolved = config ?? { disabled: [], rules: [] };
  const merged = [...resolved.rules, ...builtInRules].filter(
    (r) => !resolved.disabled.includes(r.name),
  );
  return new FilterRegistry(merged);
}
