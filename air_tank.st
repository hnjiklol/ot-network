(* Air Tank PLC program for OTForge / OpenPLC
   - HMI/Workstation turns the air pump on/off with Modbus coil 0
   - HMI/Workstation reads tank pressure from Modbus holding register 0
     (value is bar x 100, e.g. 523 = 5.23 bar) *)
PROGRAM main
  VAR
    (* --- Exposed to the HMI / Workstation (PLC's own Modbus server) --- *)
    pump_cmd      AT %QX0.0 : BOOL;   (* Coil 0: HMI writes 1 = run, 0 = stop *)
    pump_running  AT %QX0.1 : BOOL;   (* Coil 1: read-only status for the HMI *)
    tank_pressure AT %QW0   : INT;    (* Holding reg 0: pressure, bar x 100 *)

    (* --- Wired to the Air Tank process unit (OpenPLC polls it as Modbus master) --- *)
    sim_pump      AT %QX100.0 : BOOL; (* Process-sim coil 0: PUMP_CMD *)
    sim_pressure  AT %IW103   : INT;  (* Process-sim HR 3: PRESSURE_PV, bar x 100 *)
  END_VAR

  (* Pass the operator's command straight through to the pump *)
  sim_pump := pump_cmd;
  pump_running := sim_pump;

  (* Publish the tank pressure so the HMI can read it *)
  tank_pressure := sim_pressure;
END_PROGRAM

CONFIGURATION config0
  TASK task0(INTERVAL := T#100ms, PRIORITY := 0);
  PROGRAM inst0 WITH task0 : main;
END_CONFIGURATION
