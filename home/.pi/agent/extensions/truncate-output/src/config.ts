import { FilterRule } from "./filter-engine.js";

export interface ResolvedConfig {
  disabled: string[];
  rules: FilterRule[];
}
