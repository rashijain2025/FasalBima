// src/types/domain.ts

export type ClaimStatus = "Pending" | "In Review" | "Approved" | "Rejected";
export type DamageSeverity = "Low" | "Medium" | "High" | "Severe";

export interface Farmer {
  id: string;
  name: string;
  village: string;
  district: string;
  state: string;
  phone: string;
  totalCrops: number;
  openClaims: number;
}

export interface Crop {
  id: string;
  farmerName: string;
  cropType: string;
  season: string;
  stage: string;
  areaAcre: number;
  health: "Healthy" | "Stressed" | "Damaged";
}

export interface Claim {
  id: string;
  farmerName: string;
  cropType: string;
  damageType: string;
  severity: DamageSeverity;
  status: ClaimStatus;
  createdAt: string;
  village: string;
  district: string;
  /** Optional coordinates for map (lat, lng) */
  lat?: number;
  lng?: number;
  /** Backend-enriched fields */
  imageUrls?: string[];
  evidences?: { id: string; url: string; uploaded_at?: string }[];
  mlDamagePrediction?: string;
  adminNotes?: string;
  claimReason?: string;
  estimatedLossAmount?: number;
  description?: string;
}


export interface ImageReviewItem {
  id: string;
  farmerName: string;
  cropType: string;
  stage: string;
  damageType?: string;
  severity: DamageSeverity;
  quality: "OK" | "Low Quality";
  capturedAt: string;
  district: string;
  state: string;
}
