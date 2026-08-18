import { useRef } from "react";
import { useFrame } from "@react-three/fiber";
import type { Group } from "three";

/**
 * Procedural stylized cricket character. Pops onto the pitch and bobs in
 * place. Swap this for a transparent GLTF/WebM-alpha asset
 * (`useGLTF` / a sprite) when production art ships — the animation
 * contract (mount → pop-in) stays the same.
 */
export function CharacterPop() {
  const group = useRef<Group>(null);
  const elapsed = useRef(0);

  useFrame((_, delta) => {
    elapsed.current += delta;
    const k = Math.min(1, elapsed.current / 0.8); // pop-in progress
    // Ease-out-back scale: overshoot then settle at 1.
    const scale = k < 1 ? 1 + 0.35 * Math.sin((k - 1) * Math.PI) : 1;
    const walkIn = (1 - k) * 1.6;
    if (group.current) {
      group.current.scale.setScalar(Math.max(0.001, scale));
      group.current.position.set(walkIn, Math.sin(elapsed.current * 5) * 0.06, 0);
      group.current.rotation.y = Math.sin(elapsed.current * 3) * 0.08;
    }
  });

  return (
    <group ref={group}>
      {/* body */}
      <mesh position={[0, -0.55, 0]}>
        <capsuleGeometry args={[0.22, 0.45, 4, 8]} />
        <meshStandardMaterial color="#1d4ed8" />
      </mesh>
      {/* head */}
      <mesh position={[0, 0.35, 0]}>
        <sphereGeometry args={[0.16, 16, 16]} />
        <meshStandardMaterial color="#f3c98b" />
      </mesh>
      {/* helmet */}
      <mesh position={[0, 0.44, 0]}>
        <sphereGeometry args={[0.13, 16, 16, 0, Math.PI * 2, 0, Math.PI / 2]} />
        <meshStandardMaterial color="#ef4444" />
      </mesh>
      {/* bat */}
      <mesh position={[0.42, -0.4, 0]} rotation={[0, 0, -0.5]}>
        <cylinderGeometry args={[0.035, 0.035, 0.7, 8]} />
        <meshStandardMaterial color="#a16207" />
      </mesh>
    </group>
  );
}
