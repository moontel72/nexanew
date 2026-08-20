<?php

namespace Database\Factories;

use App\Models\Cricket\CricketManager;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CricketManager>
 */
class CricketManagerFactory extends Factory
{
    protected $model = CricketManager::class;

    /**
     * Define the model's default state.
     *
     * `password` is given in plain text — the model's setPasswordAttribute
     * mutator hashes it on assignment.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'password' => 'password',
            'phone' => fake()->phoneNumber(),
            'status' => 'active',
            'permissions' => [
                'can_manage_scores' => true,
                'can_manage_streams' => false,
                'can_manage_sponsors' => false,
                'can_access_studio' => false,
            ],
        ];
    }

    /**
     * Grant the manager Todd Studio (director) access.
     */
    public function withStudioAccess(): static
    {
        return $this->state(fn (array $attributes) => [
            'permissions' => array_merge(
                $attributes['permissions'] ?? [],
                ['can_access_studio' => true]
            ),
        ]);
    }

    /**
     * Suspend the manager account.
     */
    public function suspended(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'suspended',
        ]);
    }
}
