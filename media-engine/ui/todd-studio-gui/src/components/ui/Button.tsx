import { forwardRef, type ButtonHTMLAttributes } from "react";
import { cn } from "../../lib/utils";

type Variant = "default" | "secondary" | "ghost" | "destructive" | "outline";

const variants: Record<Variant, string> = {
  default: "bg-primary text-primary-foreground hover:bg-primary/90",
  secondary: "bg-muted text-muted-foreground hover:bg-muted/80",
  ghost: "hover:bg-muted",
  outline: "border border-border hover:bg-muted",
  destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
};

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
}

/** Lightweight shadcn-style button (no Radix dependency). */
export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "default", ...props }, ref) => (
    <button
      ref={ref}
      className={cn(
        "inline-flex items-center justify-center rounded-md px-3 py-1.5 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
        variants[variant],
        className,
      )}
      {...props}
    />
  ),
);
Button.displayName = "Button";
