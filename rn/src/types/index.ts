export interface UserProfile {
  id?: number;
  name: string;
  dob: string;
  pcp: string;
  healthConditions: string;
  pharmacy: string;
}

export interface Medication {
  id?: number;
  profile_id: number;
  name: string;
  dosage: string;
  additionalInfo: string;
  imageUrl: string;
}
