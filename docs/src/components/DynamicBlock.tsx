import React, {useEffect, useState} from 'react';

/**
 * Dynamic content block — fetches a Super Admin-edited block from
 * `/api/v1/public/content/{slug}` at runtime and renders its text and
 * screenshot. Renders `placeholder` when no live block exists yet, so the
 * manual never breaks before the admin fills the content in.
 *
 * Block payload shape (set via the Super Admin panel):
 *   { title: string, image: '/storage/site-content/…png',
 *     text_en: string, text_ur: string }
 */
export default function DynamicBlock({
  slug,
  title,
  placeholder,
}: {
  slug: string;
  title: string;
  placeholder?: React.ReactNode;
}): React.JSX.Element {
  const [payload, setPayload] = useState<any>(null);

  useEffect(() => {
    let alive = true;
    fetch(`/api/v1/public/content/${slug}`)
      .then((res) => (res.ok ? res.json() : null))
      .then((json) => {
        if (alive && json && json.success && json.data && json.data.payload) {
          setPayload(json.data.payload);
        }
      })
      .catch(() => {
        // Offline or block not created yet — keep the placeholder.
      });
    return () => {
      alive = false;
    };
  }, [slug]);

  if (!payload) {
    return <>{placeholder ?? null}</>;
  }

  return (
    <figure className="screenshot-figure">
      {payload.image ? (
        <img src={payload.image} alt={payload.title ?? title} loading="lazy" />
      ) : null}
      <figcaption>{payload.title ?? title}</figcaption>
      {payload.text_en || payload.text_ur ? (
        <div className="dynamic-block-text">
          {payload.text_en ? <p>{payload.text_en}</p> : null}
          {payload.text_ur ? (
            <p>
              <em>{payload.text_ur}</em>
            </p>
          ) : null}
        </div>
      ) : null}
    </figure>
  );
}
