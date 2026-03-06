import { memo } from "react";

type Point = {
  label: string;
  value: number;
};

type ChartCardProps = {
  title: string;
  subtitle: string;
  points: Point[];
  variant: "line" | "bars";
};

function getLinePath(points: Point[]) {
  if (points.length === 0) return "";
  const width = 100;
  const height = 60;
  const max = Math.max(...points.map((p) => p.value), 1);

  return points
    .map((p, index) => {
      const x = (index / (points.length - 1 || 1)) * width;
      const y = height - (p.value / max) * height;
      return `${index === 0 ? "M" : "L"}${x},${y}`;
    })
    .join(" ");
}

function getBarLevel(value: number): string {
  if (value >= 80) return "bar-l5";
  if (value >= 65) return "bar-l4";
  if (value >= 50) return "bar-l3";
  if (value >= 35) return "bar-l2";
  return "bar-l1";
}

function ChartCardComponent({ title, subtitle, points, variant }: ChartCardProps) {
  return (
    <article className="chart-card">
      <div className="card-head">
        <div>
          <h3>{title}</h3>
          <p>{subtitle}</p>
        </div>
      </div>

      {variant === "line" ? (
        <div className="chart-canvas">
          <svg viewBox="0 0 100 60" className="line-chart" role="img" aria-label={title}>
            <path d={getLinePath(points)} />
          </svg>
          <div className="x-axis-labels">
            {points.map((point) => (
              <span key={point.label}>{point.label}</span>
            ))}
          </div>
        </div>
      ) : (
        <div className="chart-canvas bars-chart" role="img" aria-label={title}>
          {points.map((point) => (
            <div key={point.label} className="bar-col">
              <div className="bar-track">
                <div className={`bar-fill ${getBarLevel(point.value)}`} />
              </div>
              <span>{point.label}</span>
            </div>
          ))}
        </div>
      )}
    </article>
  );
}

const ChartCard = memo(ChartCardComponent);

export default ChartCard;
