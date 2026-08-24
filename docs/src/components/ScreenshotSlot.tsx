import React from 'react';

/**
 * Screenshot slot — shows the REAL screenshot when `src` is provided,
 * otherwise renders a clearly-marked placeholder callout so field operators
 * know which screen the step refers to even before the image exists.
 *
 * Usage:
 *   <ScreenshotSlot
 *     title="Login screen"
 *     src="/img/screenshots/book2-login.png"
 *   >
 *     Capture the login screen and the session bar.
 *   </ScreenshotSlot>
 */
export default function ScreenshotSlot({
  title,
  src,
  alt,
  children,
}: {
  title: string;
  src?: string;
  alt?: string;
  children: React.ReactNode;
}): React.JSX.Element {
  if (src) {
    return (
      <figure className="screenshot-figure">
        <img src={src} alt={alt ?? title} loading="lazy" />
        <figcaption>{title}</figcaption>
      </figure>
    );
  }

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
