// src/data/mockData.ts
import type {
  Farmer,
  Crop,
  Claim,
  ImageReviewItem,
  DamageSeverity,
  ClaimStatus,
} from "../types/domain";

export interface ReviewImage {
  id: string;
  farmerName: string;
  cropType: string;
  stage: string;
  village: string;
  district: string;
  state: string;
  status: ClaimStatus;        // tie to claim status colors
  reviewStatus: string;       // e.g. "Auto-flagged", "Needs review"
  severity?: DamageSeverity;  // optional – model's damage severity
  damageType?: string;
  timestamp: string;
  imageUrl?: string;          // optional for when you have real URLs
}

export const MOCK_IMAGES: ReviewImage[] = [
  {
    id: "IMG-1001",
    farmerName: "Ramprasad Sharma",
    cropType: "Soybean",
    stage: "Vegetative",
    village: "Badagaon",
    district: "Gwalior",
    state: "Madhya Pradesh",
    status: "In Review",
    reviewStatus: "Auto-flagged",
    severity: "Severe",
    damageType: "Flood Inundation",
    timestamp: "2025-11-28 10:15",
    imageUrl: "", // later: actual URL
  },
  {
    id: "IMG-1002",
    farmerName: "Kamla Bai",
    cropType: "Mustard",
    stage: "Flowering",
    village: "Ater",
    district: "Bhind",
    state: "Madhya Pradesh",
    status: "Pending",
    reviewStatus: "Needs review",
    severity: "High",
    damageType: "Water Stress / Drought",
    timestamp: "2025-11-28 11:02",
    imageUrl: "",
  },
  {
    id: "IMG-1003",
    farmerName: "Shivraj Singh",
    cropType: "Wheat",
    stage: "Early tillering",
    village: "Joura",
    district: "Morena",
    state: "Madhya Pradesh",
    status: "Approved",
    reviewStatus: "Reviewed",
    severity: "Medium",
    damageType: "Mild Pest Attack",
    timestamp: "2025-11-27 17:45",
    imageUrl: "",
  },
];

// ------------ Plot verification mocks ------------

export type PlotVerificationStatus =
  | "Unverified"
  | "Verified"
  | "Rejected"
  | "Needs field visit";

export type MismatchLevel = "None" | "Low" | "High";

export interface PlotDocument {
  id: string;
  plotId: string;
  claimId?: string;
  docType: "Land record" | "Patta" | "Aadhaar" | "Bank passbook" | "Other";
  docNumber: string;
  uploadedAt: string;
  fileName: string;
  fileUrl?: string; // when you have real URLs from backend
}

export interface PlotVerificationRecord {
  id: string;                // internal plot id
  claimId?: string;          // link to claim if any
  farmerName: string;
  village: string;
  district: string;
  state: string;
  khataNumber: string;
  khasraNumber: string;
  claimedAreaHa: number;     // claimed area (hectares)
  gisAreaHa: number;         // GIS / FMB derived area
  mismatchLevel: MismatchLevel;
  mismatchReason?: string;
  verificationStatus: PlotVerificationStatus;
  createdAt: string;
  lastUpdated: string;
  documents: PlotDocument[];
}

export const MOCK_PLOTS: PlotVerificationRecord[] = [
  {
    id: "PLOT-1001",
    claimId: "CLM-9001",
    farmerName: "Ramprasad Sharma",
    village: "Badagaon",
    district: "Gwalior",
    state: "Madhya Pradesh",
    khataNumber: "45/2",
    khasraNumber: "128/3",
    claimedAreaHa: 1.20,
    gisAreaHa: 1.05,
    mismatchLevel: "High",
    mismatchReason: "Claimed area > GIS boundary by 0.15 ha",
    verificationStatus: "Needs field visit",
    createdAt: "2025-11-20",
    lastUpdated: "2025-11-28",
    documents: [
      {
        id: "DOC-5001",
        plotId: "PLOT-1001",
        claimId: "CLM-9001",
        docType: "Land record",
        docNumber: "LR-2025-78-09",
        uploadedAt: "2025-11-21 10:15",
        fileName: "land_record_ramprasad_sharma.pdf",
      },
      {
        id: "DOC-5002",
        plotId: "PLOT-1001",
        claimId: "CLM-9001",
        docType: "Patta",
        docNumber: "PATTA-88213",
        uploadedAt: "2025-11-21 10:17",
        fileName: "patta_ramprasad_sharma.pdf",
      },
    ],
  },
  {
    id: "PLOT-1002",
    claimId: "CLM-9002",
    farmerName: "Kamla Bai",
    village: "Ater",
    district: "Bhind",
    state: "Madhya Pradesh",
    khataNumber: "12/1",
    khasraNumber: "77/1",
    claimedAreaHa: 0.80,
    gisAreaHa: 0.78,
    mismatchLevel: "Low",
    mismatchReason: "Minor 0.02 ha offset within tolerance limit",
    verificationStatus: "Unverified",
    createdAt: "2025-11-22",
    lastUpdated: "2025-11-25",
    documents: [
      {
        id: "DOC-5003",
        plotId: "PLOT-1002",
        claimId: "CLM-9002",
        docType: "Land record",
        docNumber: "LR-2025-11-02",
        uploadedAt: "2025-11-22 09:30",
        fileName: "land_record_kamla_bai.pdf",
      },
    ],
  },
  {
    id: "PLOT-1003",
    claimId: "CLM-9003",
    farmerName: "Shivraj Singh",
    village: "Joura",
    district: "Morena",
    state: "Madhya Pradesh",
    khataNumber: "9/3",
    khasraNumber: "201/4",
    claimedAreaHa: 1.50,
    gisAreaHa: 1.50,
    mismatchLevel: "None",
    mismatchReason: undefined,
    verificationStatus: "Verified",
    createdAt: "2025-11-15",
    lastUpdated: "2025-11-24",
    documents: [
      {
        id: "DOC-5004",
        plotId: "PLOT-1003",
        claimId: "CLM-9003",
        docType: "Land record",
        docNumber: "LR-2025-55-33",
        uploadedAt: "2025-11-16 13:10",
        fileName: "land_record_shivraj_singh.pdf",
      },
      {
        id: "DOC-5005",
        plotId: "PLOT-1003",
        claimId: "CLM-9003",
        docType: "Aadhaar",
        docNumber: "XXXX-XXXX-1234",
        uploadedAt: "2025-11-16 13:12",
        fileName: "aadhaar_shivraj_singh.pdf",
      },
    ],
  },
  {
    id: "PLOT-1004",
    claimId: "CLM-9004",
    farmerName: "Lakhwinder Singh",
    village: "Mehal Kalan",
    district: "Barnala",
    state: "Punjab",
    khataNumber: "88/4",
    khasraNumber: "341/2",
    claimedAreaHa: 2.80,
    gisAreaHa: 2.80,
    mismatchLevel: "None",
    mismatchReason: undefined,
    verificationStatus: "Verified",
    createdAt: "2025-11-18",
    lastUpdated: "2025-11-26",
    documents: [
      {
        id: "DOC-5006",
        plotId: "PLOT-1004",
        claimId: "CLM-9004",
        docType: "Land record",
        docNumber: "PB-LR-4421",
        uploadedAt: "2025-11-19 11:20",
        fileName: "jamabandi_lakhwinder.pdf",
      },
    ],
  },
  {
    id: "PLOT-1005",
    claimId: "CLM-9005",
    farmerName: "Baldev Patel",
    village: "Petlad",
    district: "Anand",
    state: "Gujarat",
    khataNumber: "104/1",
    khasraNumber: "512/8",
    claimedAreaHa: 3.40,
    gisAreaHa: 2.95,
    mismatchLevel: "High",
    mismatchReason: "Canal buffer encroachment detected by satellite imagery",
    verificationStatus: "Needs field visit",
    createdAt: "2025-11-12",
    lastUpdated: "2025-11-27",
    documents: [
      {
        id: "DOC-5007",
        plotId: "PLOT-1005",
        claimId: "CLM-9005",
        docType: "Land record",
        docNumber: "GJ-7-12-882",
        uploadedAt: "2025-11-13 14:05",
        fileName: "7_12_extract_patel.pdf",
      },
    ],
  },
  {
    id: "PLOT-1006",
    claimId: "CLM-9006",
    farmerName: "Dinesh Bishnoi",
    village: "Osian",
    district: "Jodhpur",
    state: "Rajasthan",
    khataNumber: "56/3",
    khasraNumber: "198/1",
    claimedAreaHa: 4.50,
    gisAreaHa: 4.42,
    mismatchLevel: "Low",
    mismatchReason: "Minor fence alignment variance",
    verificationStatus: "Unverified",
    createdAt: "2025-11-21",
    lastUpdated: "2025-11-27",
    documents: [
      {
        id: "DOC-5008",
        plotId: "PLOT-1006",
        claimId: "CLM-9006",
        docType: "Patta",
        docNumber: "RJ-PAT-9912",
        uploadedAt: "2025-11-21 16:40",
        fileName: "patta_jodhpur_bishnoi.pdf",
      },
    ],
  },
  {
    id: "PLOT-1007",
    claimId: "CLM-9007",
    farmerName: "Vitthal Shinde",
    village: "Barshi",
    district: "Solapur",
    state: "Maharashtra",
    khataNumber: "78/2",
    khasraNumber: "402/3",
    claimedAreaHa: 2.10,
    gisAreaHa: 2.10,
    mismatchLevel: "None",
    mismatchReason: undefined,
    verificationStatus: "Verified",
    createdAt: "2025-11-10",
    lastUpdated: "2025-11-22",
    documents: [
      {
        id: "DOC-5009",
        plotId: "PLOT-1007",
        claimId: "CLM-9007",
        docType: "Land record",
        docNumber: "MH-712-402",
        uploadedAt: "2025-11-11 10:00",
        fileName: "satbara_shinde.pdf",
      },
    ],
  },
  {
    id: "PLOT-1008",
    claimId: "CLM-9008",
    farmerName: "Rameshwar Yadav",
    village: "Pindra",
    district: "Varanasi",
    state: "Uttar Pradesh",
    khataNumber: "22/5",
    khasraNumber: "145/2",
    claimedAreaHa: 1.10,
    gisAreaHa: 1.10,
    mismatchLevel: "None",
    mismatchReason: undefined,
    verificationStatus: "Verified",
    createdAt: "2025-11-23",
    lastUpdated: "2025-11-28",
    documents: [
      {
        id: "DOC-5010",
        plotId: "PLOT-1008",
        claimId: "CLM-9008",
        docType: "Land record",
        docNumber: "UP-KHATA-145",
        uploadedAt: "2025-11-24 12:15",
        fileName: "khatauni_yadav.pdf",
      },
    ],
  },
];

export const MOCK_FARMERS: Farmer[] = [
  {
    id: "FARM-001",
    name: "Shivraj Singh",
    village: "Joura",
    district: "Morena",
    state: "Madhya Pradesh",
    phone: "+91-9876543210",
    totalCrops: 3,
    openClaims: 1,
  },
  {
    id: "FARM-002",
    name: "Kamla Bai",
    village: "Ater",
    district: "Bhind",
    state: "Madhya Pradesh",
    phone: "+91-9876500001",
    totalCrops: 2,
    openClaims: 2,
  },
  {
    id: "FARM-003",
    name: "Ramprasad Sharma",
    village: "Badagaon",
    district: "Gwalior",
    state: "Madhya Pradesh",
    phone: "+91-9000012345",
    totalCrops: 1,
    openClaims: 1,
  },
  {
    id: "FARM-004",
    name: "Lakhwinder Singh",
    village: "Mehal Kalan",
    district: "Barnala",
    state: "Punjab",
    phone: "+91-9814567890",
    totalCrops: 2,
    openClaims: 1,
  },
  {
    id: "FARM-005",
    name: "Baldev Patel",
    village: "Petlad",
    district: "Anand",
    state: "Gujarat",
    phone: "+91-9426789012",
    totalCrops: 3,
    openClaims: 1,
  },
  {
    id: "FARM-006",
    name: "Dinesh Bishnoi",
    village: "Osian",
    district: "Jodhpur",
    state: "Rajasthan",
    phone: "+91-9784561230",
    totalCrops: 2,
    openClaims: 1,
  },
  {
    id: "FARM-007",
    name: "Vitthal Shinde",
    village: "Barshi",
    district: "Solapur",
    state: "Maharashtra",
    phone: "+91-9158901234",
    totalCrops: 4,
    openClaims: 1,
  },
  {
    id: "FARM-008",
    name: "Rameshwar Yadav",
    village: "Pindra",
    district: "Varanasi",
    state: "Uttar Pradesh",
    phone: "+91-9415678901",
    totalCrops: 2,
    openClaims: 1,
  },
];

export const MOCK_CROPS: Crop[] = [
  {
    id: "CROP-001",
    farmerName: "Shivraj Singh",
    cropType: "Wheat",
    season: "Rabi 2025",
    stage: "Tillering",
    areaAcre: 2.5,
    health: "Healthy",
  },
  {
    id: "CROP-002",
    farmerName: "Kamla Bai",
    cropType: "Mustard",
    season: "Rabi 2025",
    stage: "Flowering",
    areaAcre: 1.8,
    health: "Stressed",
  },
  {
    id: "CROP-003",
    farmerName: "Ramprasad Sharma",
    cropType: "Soybean",
    season: "Kharif 2025",
    stage: "Pod Formation",
    areaAcre: 3.2,
    health: "Damaged",
  },
  {
    id: "CROP-004",
    farmerName: "Lakhwinder Singh",
    cropType: "Paddy (Rice)",
    season: "Kharif 2025",
    stage: "Grain Filling",
    areaAcre: 6.5,
    health: "Damaged",
  },
  {
    id: "CROP-005",
    farmerName: "Baldev Patel",
    cropType: "Cotton",
    season: "Kharif 2025",
    stage: "Boll Opening",
    areaAcre: 8.0,
    health: "Stressed",
  },
  {
    id: "CROP-006",
    farmerName: "Dinesh Bishnoi",
    cropType: "Mustard",
    season: "Rabi 2025",
    stage: "Pod Development",
    areaAcre: 11.2,
    health: "Damaged",
  },
  {
    id: "CROP-007",
    farmerName: "Vitthal Shinde",
    cropType: "Sugarcane",
    season: "Annual 2025",
    stage: "Grand Growth",
    areaAcre: 5.0,
    health: "Stressed",
  },
  {
    id: "CROP-008",
    farmerName: "Rameshwar Yadav",
    cropType: "Wheat",
    season: "Rabi 2025",
    stage: "Vegetative",
    areaAcre: 2.7,
    health: "Stressed",
  },
];

export const MOCK_CLAIMS: Claim[] = [
  {
    id: "CLM-9001",
    farmerName: "Ramprasad Sharma",
    cropType: "Soybean",
    damageType: "Flood Inundation",
    severity: "Severe",
    status: "In Review",
    createdAt: "2025-11-26 10:05",
    village: "Badagaon",
    district: "Gwalior",
    lat: 26.2183,
    lng: 78.1828,
  },
  {
    id: "CLM-9002",
    farmerName: "Kamla Bai",
    cropType: "Mustard",
    damageType: "Water Stress / Drought",
    severity: "High",
    status: "Pending",
    createdAt: "2025-11-27 13:22",
    village: "Ater",
    district: "Bhind",
    lat: 26.5613,
    lng: 78.7885,
  },
  {
    id: "CLM-9003",
    farmerName: "Shivraj Singh",
    cropType: "Wheat",
    damageType: "Mild Pest Attack",
    severity: "Medium",
    status: "Approved",
    createdAt: "2025-11-25 09:40",
    village: "Joura",
    district: "Morena",
    lat: 26.5000,
    lng: 78.0000,
  },
  {
    id: "CLM-9004",
    farmerName: "Lakhwinder Singh",
    cropType: "Paddy (Rice)",
    damageType: "Unseasonal Hailstorm",
    severity: "Severe",
    status: "In Review",
    createdAt: "2025-11-24 16:15",
    village: "Mehal Kalan",
    district: "Barnala",
    lat: 30.3800,
    lng: 75.5400,
  },
  {
    id: "CLM-9005",
    farmerName: "Baldev Patel",
    cropType: "Cotton",
    damageType: "Pink Bollworm Infestation",
    severity: "High",
    status: "Pending",
    createdAt: "2025-11-23 11:30",
    village: "Petlad",
    district: "Anand",
    lat: 22.4700,
    lng: 72.8000,
  },
  {
    id: "CLM-9006",
    farmerName: "Dinesh Bishnoi",
    cropType: "Mustard",
    damageType: "Frost & Cold Wave",
    severity: "Severe",
    status: "In Review",
    createdAt: "2025-11-22 08:45",
    village: "Osian",
    district: "Jodhpur",
    lat: 26.7200,
    lng: 72.9000,
  },
  {
    id: "CLM-9007",
    farmerName: "Vitthal Shinde",
    cropType: "Sugarcane",
    damageType: "Crop Lodging & Wind Damage",
    severity: "Medium",
    status: "Approved",
    createdAt: "2025-11-21 14:10",
    village: "Barshi",
    district: "Solapur",
    lat: 18.2300,
    lng: 75.6900,
  },
  {
    id: "CLM-9008",
    farmerName: "Rameshwar Yadav",
    cropType: "Wheat",
    damageType: "Yellow Rust Fungal Attack",
    severity: "High",
    status: "In Review",
    createdAt: "2025-11-20 10:50",
    village: "Pindra",
    district: "Varanasi",
    lat: 25.5400,
    lng: 82.8500,
  },
];

export const MOCK_IMAGE_QUEUE: ImageReviewItem[] = [
  {
    id: "IMG-1001",
    farmerName: "Ramprasad Sharma",
    cropType: "Soybean",
    stage: "Pod Formation",
    damageType: "Flood Inundation",
    severity: "Severe",
    quality: "OK",
    capturedAt: "2025-11-25 11:40",
    district: "Gwalior",
    state: "Madhya Pradesh",
  },
  {
    id: "IMG-1002",
    farmerName: "Kamla Bai",
    cropType: "Mustard",
    stage: "Flowering",
    damageType: "Water Stress",
    severity: "High",
    quality: "OK",
    capturedAt: "2025-11-26 17:05",
    district: "Bhind",
    state: "Madhya Pradesh",
  },
  {
    id: "IMG-1003",
    farmerName: "Shivraj Singh",
    cropType: "Wheat",
    stage: "Tillering",
    damageType: undefined,
    severity: "Low",
    quality: "Low Quality",
    capturedAt: "2025-11-27 09:25",
    district: "Morena",
    state: "Madhya Pradesh",
  },
];

export const severityColor: Record<DamageSeverity, string> = {
  Severe: "bg-red-800 text-white",        
  High: "bg-orange-500 text-white",       
  Medium: "bg-yellow-300 text-slate-900",
  Low: "bg-emerald-500 text-white",      
};

export const statusColor: Record<ClaimStatus, string> = {
  Pending: "bg-slate-400 text-white",
  "In Review": "bg-blue-500 text-white",
  Approved: "bg-emerald-600 text-white",
  Rejected: "bg-red-600 text-white",
};
