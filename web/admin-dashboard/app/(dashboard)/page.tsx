import dynamic from "next/dynamic";
import { Activity, DollarSign, HeartPulse, Users } from "lucide-react";
import StatCard from "@/components/dashboard/StatCard";
import TableCard from "@/components/dashboard/TableCard";

const ChartCard = dynamic(() => import("@/components/dashboard/ChartCard"), {
  ssr: false,
  loading: () => <div className="chart-card loading-card">Loading chart...</div>,
});

const userGrowth = [
  { label: "Mon", value: 30 },
  { label: "Tue", value: 36 },
  { label: "Wed", value: 42 },
  { label: "Thu", value: 39 },
  { label: "Fri", value: 48 },
  { label: "Sat", value: 54 },
  { label: "Sun", value: 58 },
];

const subscriptionTrend = [
  { label: "Jan", value: 40 },
  { label: "Feb", value: 52 },
  { label: "Mar", value: 48 },
  { label: "Apr", value: 62 },
  { label: "May", value: 70 },
  { label: "Jun", value: 75 },
];

const recentUsers = [
  {
    name: "Ava Thompson",
    email: "ava.thompson@datox.app",
    plan: "Premium",
    status: "active" as const,
    createdAt: "2026-03-04",
  },
  {
    name: "Noah Carter",
    email: "noah.carter@datox.app",
    plan: "Basic",
    status: "pending" as const,
    createdAt: "2026-03-03",
  },
  {
    name: "Mia Rodriguez",
    email: "mia.rodriguez@datox.app",
    plan: "Premium",
    status: "active" as const,
    createdAt: "2026-03-02",
  },
  {
    name: "Liam Brooks",
    email: "liam.brooks@datox.app",
    plan: "Basic",
    status: "paused" as const,
    createdAt: "2026-03-01",
  },
];

export default function OverviewPage() {
  return (
    <div className="overview-grid">
      <section className="kpi-grid">
        <StatCard title="Total Users" value="24,981" trendText="+8.2% vs last month" trend="up" icon={Users} />
        <StatCard
          title="Active Subscriptions"
          value="8,124"
          trendText="+4.1% conversion"
          trend="up"
          icon={Activity}
        />
        <StatCard
          title="Monthly Revenue"
          value="$128,430"
          trendText="+11.3% growth"
          trend="up"
          icon={DollarSign}
        />
        <StatCard
          title="System Health"
          value="99.95%"
          trendText="-0.02% latency drift"
          trend="down"
          icon={HeartPulse}
        />
      </section>

      <section className="charts-grid">
        <ChartCard title="User Growth" subtitle="New signups this week" points={userGrowth} variant="line" />
        <ChartCard title="Subscription Trend" subtitle="Paid plan distribution" points={subscriptionTrend} variant="bars" />
      </section>

      <section className="bottom-grid">
        <TableCard title="Recent Users" rows={recentUsers} />
        <article className="activity-card">
          <div className="card-head">
            <div>
              <h3>Recent Activity</h3>
              <p>Live operational feed</p>
            </div>
          </div>
          <ul>
            <li>
              <span className="dot dot-success" />
              <div>
                <strong>Subscription upgraded</strong>
                <p>Emma moved to Premium plan</p>
              </div>
              <time>2m ago</time>
            </li>
            <li>
              <span className="dot dot-warning" />
              <div>
                <strong>Verification pending</strong>
                <p>3 profiles awaiting review</p>
              </div>
              <time>14m ago</time>
            </li>
            <li>
              <span className="dot dot-info" />
              <div>
                <strong>System event</strong>
                <p>Background sync completed</p>
              </div>
              <time>31m ago</time>
            </li>
          </ul>
        </article>
      </section>
    </div>
  );
}
