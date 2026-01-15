export default function DashboardPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <div className="rounded-lg border bg-card p-8">
        <h2 className="text-2xl font-semibold">Welcome!</h2>
        <p className="mt-2 text-muted-foreground">
          This is your dashboard. You can navigate to Setup Categories from the
          sidebar.
          Test Auto Deploy to Main
        </p>
      </div>
    </div>
  );
}
