import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function ProfilePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Learner Profile</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Manage your learning goals, target pace, and environment preferences.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Profile Details</CardTitle>
            <CardDescription>Your public identity within IT Lab OS</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="display-name">Display Name</Label>
              <Input id="display-name" defaultValue="Engineer" />
            </div>

            <div>
              <Label htmlFor="experience">Experience Level</Label>
              <Input id="experience" defaultValue="Junior / Mid System Administrator" />
            </div>

            <Button>Save Changes</Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Learning Schedule</CardTitle>
            <CardDescription>Daily cadence used for mission sizing</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="daily-target">Daily Target Time (Minutes)</Label>
              <Input id="daily-target" type="number" defaultValue="45" />
            </div>

            <div>
              <Label htmlFor="primary-goal">Primary Goal</Label>
              <Input id="primary-goal" defaultValue="Master Production Systems & Cloud Networking" />
            </div>

            <Button variant="secondary">Update Schedule</Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
