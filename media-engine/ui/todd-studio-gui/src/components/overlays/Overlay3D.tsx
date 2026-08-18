import type { ReactNode } from "react";
import { Canvas } from "@react-three/fiber";

export interface Overlay3DProps {
  children: ReactNode;
}

/**
 * Transparent WebGL composition layer for spatial overlays. Rendered
 * above the program monitor; pointer events pass through to the UI
 * below.
 */
export function Overlay3D({ children }: Overlay3DProps) {
  return (
    <div className="pointer-events-none absolute inset-0 z-20">
      <Canvas
        gl={{ alpha: true, antialias: true }}
        camera={{ position: [0, 0, 3.5], fov: 50 }}
        style={{ background: "transparent" }}
      >
        <ambientLight intensity={0.8} />
        <directionalLight position={[2, 2, 2]} intensity={1.1} />
        {children}
      </Canvas>
    </div>
  );
}
