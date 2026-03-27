// contracts/shared-types.ts
// ⚠️ AUTO-GENERATED from api-spec.yaml — DO NOT EDIT MANUALLY
// Regenerate: bash scripts/generate-types.sh <project-path>

// --- Common Types ---

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
}

export interface ApiError {
  /** Error code from errors.yaml */
  code: string;
  message: string;
}

export interface Pagination {
  page: number;
  pageSize: number;
  total: number;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: Pagination;
}

// --- Domain Types ---
// Add project-specific types below.
// These should match the schemas defined in api-spec.yaml.
