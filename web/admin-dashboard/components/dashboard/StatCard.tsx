import { memo } from "react";
import { ArrowDownRight, ArrowUpRight, LucideIcon, Minus } from "lucide-react";

type StatCardProps = {
  title: string;
  value: string;
  trendText: string;
  trend: "up" | "down" | "neutral";
  icon: LucideIcon;
};

function StatCardComponent({ title, value, trendText, trend, icon: Icon }: StatCardProps) {
  return (
    <article className="stat-card">
      <div className="stat-head">
        <span className="stat-title">{title}</span>
        <div className="stat-icon-wrap">
          <Icon className="icon-16" />
        </div>
      </div>
      <p className="stat-value">{value}</p>
      <p className={`stat-trend trend-${trend}`}>
        {trend === "up" ? <ArrowUpRight className="icon-14" /> : null}
        {trend === "down" ? <ArrowDownRight className="icon-14" /> : null}
        {trend === "neutral" ? <Minus className="icon-14" /> : null}
        {trendText}
      </p>
    </article>
  );
}

const StatCard = memo(StatCardComponent);

export default StatCard;
