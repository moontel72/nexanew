import React from 'react';

/**
 * Structured placeholder for screenshots that will be dropped in later.
 * Renders as a clearly-marked, print-friendly callout so field operators
 * know exactly which screen the step refers to even before the image
 * exists.
 */
export default function ScreenshotSlot({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}): React.JSX.Element {
  return (
    <div className="screenshot-slot" aria-label={`Screenshot placeholder: ${title}`}>
      <div className="screenshot-slot-icon">📸</div>
      <div className="screenshot-slot-body">
        <strong>SCREENSHOT SLOT — {title}</strong>
        <p>{children}</p>
      </div>
    </div>
  );
}
