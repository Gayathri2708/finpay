import { Response } from 'express';

interface ApiResponse {
  success: boolean;
  message: string;
  data?: unknown;
  errors?: unknown[];
}

/** Sends a standardized success response. */
export function success(
  res: Response,
  data: unknown = null,
  message: string = 'Success',
  statusCode: number = 200
): Response {
  const body: ApiResponse = { success: true, message, data };
  return res.status(statusCode).json(body);
}

/** Sends a standardized error response. */
export function error(
  res: Response,
  message: string = 'Something went wrong',
  statusCode: number = 500,
  errors: unknown[] = []
): Response {
  const body: ApiResponse = { success: false, message, errors };
  return res.status(statusCode).json(body);
}
