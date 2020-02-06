(define (domain oil_platform_inspection)
(:requirements :strips :typing :fluents :negative-preconditions :disjunctive-preconditions :durative-actions :duration-inequalities :universal-preconditions )
(:types
  robot
  observation_point
  robot_sensor
  actuator
)

(:predicates (at ?r - robot ?wp - observation_point)
             (available ?r - robot)
             (can_inspect_valve ?r - robot)
             (can_supervise_process ?r - robot)
             (close_to ?wpi  ?wpf - observation_point)
             (surface_point_at ?r -robot ?wp - observation_point)
             (equipped_for_temperature_analysis ?r - robot ?s - robot_sensor)
             (equipped_for_pression_analysis ?r - robot ?s - robot_sensor)
             (equipped_for_camera_imaging ?r - robot ?s - robot_sensor)
             (poi_pressure_analysis  ?wp - observation_point)
             (poi_temperature_analysis  ?wp - observation_point)
             (poi_image_taken  ?wp - observation_point)
             (poi_valve_inspection  ?wp - observation_point)
             (poi_valve_turned  ?wp - observation_point)
             (poi_structure_id  ?wp - observation_point)
             (poi_observation ?wp - observation_point)
             (explored ?wp - observation_point)
             (equipped_with_actuator ?r - robot ?a - actuator)

)
(:functions (energy ?r - robot)
            (consumption ?r - robot)
            (speed ?r - robot)
            (recharge_rate ?r - robot)
            (distance ?wpi ?wpf - observation_point)
            (data_adquired ?r - robot)
            (data_capacity ?r - robot)
            (total-distance)

)

(:durative-action navigation
:parameters (?r - robot ?wpi  ?wpf - observation_point)
:duration ( = ?duration (* (/ (distance ?wpi ?wpf) (speed ?r)) 2))
:condition (and
           (at start (available ?r))
           (at start (at ?r ?wpi))
           (at start (>= (energy ?r) (* (distance ?wpi ?wpf)(consumption ?r))))
           )
:effect (and
        (at start (decrease (energy ?r) (* (distance ?wpi ?wpf)(consumption ?r))))
        (at start (not (available ?r)))
        (at start (not (at ?r ?wpi)))
        (at end (at ?r ?wpf))
        (at end (explored ?wpf))
        (at end (available ?r))
        (at end (increase (total-distance) (distance ?wpi ?wpf)))
        )
)
(:durative-action data_communication
:parameters (?r - robot   ?wp - observation_point)
:duration (= ?duration 20)
:condition (and
           (over all (at ?r ?wp))
           (at start (at ?r ?wp))
           (at start (surface_point_at ?r ?wp))
           (at start (available ?r))
           (at start (>= (data_adquired ?r) (data_capacity ?r)))
           (at start (>= (energy ?r) 2))
           )
:effect (and
        (at start (not (available ?r)))
        (at end (available ?r))
        (at end (decrease (energy ?r) 2))
        (at end (assign (data_adquired ?r) 0))
        (at end (not (surface_point_at ?r ?wp)))
	 )
)
(:durative-action refuel
:parameters (?r - robot  ?wp - observation_point)
:duration (= ?duration (/ (- 100 (energy ?r)) (recharge_rate ?r)))
:condition (and
          (over all (at ?r ?wp))
          (at start (at ?r ?wp))
          (at start (surface_point_at ?r ?wp))
          (at start (available ?r))
          (at start (<= (energy ?r) 80))
           )
:effect (and
        (at start (not (available ?r)))
        (at end (available ?r))
        (at end (increase (energy ?r) (* ?duration (recharge_rate ?r))))
        (at end (not (surface_point_at ?r ?wp)))
        )
)
(:durative-action observation
 :parameters (?r - robot ?wp - observation_point ?s - robot_sensor)
 :duration (= ?duration 15)
 :condition (and
            (over all (equipped_for_camera_imaging ?r ?s))
            (over all (at ?r ?wp))
            (at start (at ?r ?wp))
            (at start (available ?r))
            (at start (>= (energy ?r) 1))
            (at start (< (data_adquired ?r) (data_capacity ?r)))
            )
 :effect (and
         (at start (not (available ?r)))
         (at start (decrease (energy ?r) 1))
         (at end (poi_observation ?wp))
         (at end (available ?r))
         (at end (increase (data_adquired ?r) 1))
         )
)
(:durative-action take_image
 :parameters (?r - robot ?s - robot_sensor  ?wp - observation_point)
 :duration (= ?duration 5)
 :condition (and
            (over all (equipped_for_camera_imaging ?r ?s))
            (over all (at ?r ?wp))
            (over all (can_supervise_process ?r))
            (at start (at ?r ?wp))
            (at start (available ?r))
            (at start (>= (energy ?r) 1))
            (at start (< (data_adquired ?r) (data_capacity ?r)))
            )
 :effect (and
         (at start (not (available ?r)))
         (at start (decrease (energy ?r) 1))
         (at end (poi_image_taken ?wp))
         (at end (available ?r))
         (at end (increase (data_adquired ?r) 1))
         )
)
(:durative-action valve_inspection
 :parameters (?r - robot   ?s - robot_sensor ?wp - observation_point)
 :duration ( = ?duration 20)
 :condition (and
             (over all (at ?r ?wp))
             (over all (can_inspect_valve ?r))
             (over all (equipped_for_camera_imaging ?r ?s))
             (at start (at ?r ?wp))
             (at start (available ?r))
             (at start (>= (energy ?r) 2))
             (at start (< (data_adquired ?r) (data_capacity ?r)))
            )
  :effect (and
          (at start (not (available ?r)))
          (at end (poi_valve_inspection ?wp))
          (at end (decrease (energy ?r) 2))
          (at end (available ?r))
          (at end (increase (data_adquired ?r) 1))
          )
)
(:durative-action check_temperature
:parameters (?r - robot ?s - robot_sensor ?wp - observation_point)
:duration (= ?duration 10)
:condition (and
           (over all (at ?r ?wp))
           (over all (equipped_for_temperature_analysis ?r ?s))
           (at start (at ?r ?wp))
           (at start (available ?r))
           (at start (>= (energy ?r) 3))
           (at start (< (data_adquired ?r) (data_capacity ?r)))
           )
:effect (and
        (at start (not (available ?r)))
        (at start (decrease (energy ?r) 3))
        (at end (poi_temperature_analysis ?wp))
        (at end (available ?r))
        (at end (increase (data_adquired ?r) 1))
        )
)
(:durative-action check_pressure
:parameters (?r - robot ?s - robot_sensor  ?wp - observation_point)
:duration (= ?duration 10)
:condition (and
           (over all (at ?r ?wp))
           (at start (at ?r ?wp))
           (at start (available ?r))
           (at start (equipped_for_pression_analysis ?r ?s))
           (at start (>= (energy ?r) 3))
           (at start (< (data_adquired ?r) (data_capacity ?r)))
           )
:effect (and
        (at start (not (available ?r)))
        (at start (decrease (energy ?r) 5))
        (at end (poi_pressure_analysis ?wp))
        (at end (available ?r))
        (at end (increase (data_adquired ?r) 1))
        )
)
(:durative-action manipulate_valve
 :parameters (?rh ?rd - robot  ?s - robot_sensor ?a - actuator ?wp - observation_point)
 :duration ( = ?duration 30)
 :condition (and
             (over all (at ?rh ?wp))
             (over all (at ?rd ?wp))
             (over all (can_supervise_process ?rd))
             (over all (equipped_for_camera_imaging ?rd ?s))
             (over all (equipped_with_actuator ?rh ?a))
             (at start (poi_valve_inspection ?wp))
             (at start (at ?rh ?wp))
             (at start (at ?rd ?wp))
             (at start (available ?rh))
             (at start (available ?rd))
             (at start (>= (energy ?rh) 2))
             (at start (>= (energy ?rd) 2))
             (at start (< (data_adquired ?rd) (data_capacity ?rd)))
            )
  :effect (and
          (at start (not (available ?rh)))
          (at start (not (available ?rd)))
          (at end (poi_valve_turned ?wp))
          (at end (decrease (energy ?rh) 2))
          (at end (decrease (energy ?rd) 2))
          (at end (available ?rh))
          (at end (available ?rd))
          (at end (increase (data_adquired ?rd) 1))
          )

)
(:action surface_point_allocation
:parameters (?r - robot ?wpi  ?wpf - waypoint)
:precondition (and
           (close_to ?wpi ?wpf)
           (at ?r ?wpi))
  :effect (surface_point_at ?r ?wpf)
          
)
)
