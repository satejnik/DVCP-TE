/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.Globalization;
using System.Text;
using System.Windows.Input;
using configui.Model;
using shared.Common;

namespace shared.Model
{
    public class Controller : BusinessObjectBase, IMatlabScript   
    {
        #region Contructs

        protected Controller(string name, int number)
        {
            Name = name + number;
            Number = number;
            Reset();
        }

        #endregion

        #region Properties

        public string Name { get; private set; }

        public int Number { get; private set; }

        private Attack attack;
        public Attack Attack
        {
            get { return attack; }
            set
            {
                if (attack == value) return;
                attack = value;
                OnPropertyChanged("Attack");
            }
        }

        public AttackMode mode;
        public AttackMode Mode
        {
            get { return mode; }
            set
            {
                if (mode == value) return;
                mode = value;
                OnPropertyChanged("Mode");
            }
        }

        public double integrityAttackValue;
        public double IntegrityAttackValue
        {
            get { return integrityAttackValue; }
            set
            {
                if (integrityAttackValue == value) return;
                integrityAttackValue = value;
                OnPropertyChanged("IntegrityAttackValue");
            }
        }

        private int start;

        [NotNegative]
        public int Start
        {
            get { return start; }
            set
            {
                if (start == value) return;
                start = value;
                OnPropertyChanged("Start");
            }
        }

        public int duration;

        [NotNegative]
        public int Duration
        {
            get { return duration; }
            set
            {
                if (duration == value) return;
                duration = value;
                OnPropertyChanged("Duration");
            }
        }

        #endregion

        #region Methods

        public void Reset()
        {
            Attack = Attack.Intergrity;
            Mode = AttackMode.None;
            IntegrityAttackValue = 0;
            Start = 10000;
            Duration = 10000;
        }

        public void SetStartRandom()
        {
            Start = GetRandom();
        }

        public void SetDurationRandom()
        {
            Duration = GetRandom();
        }

        #endregion

        #region Interfaces

        #region IMatlabScript

        public string ToScript()
        {
            var builder = new StringBuilder();
            builder.AppendLine(Matlab.CommentLine("Setting controller " + Name + " parameters."));
            builder.AppendLine(UIModel.SetParameterCommand(this, ControllerProperties.Attack, Attack.ToStringValue()));
            builder.AppendLine(UIModel.SetParameterCommand(this, ControllerProperties.AttackMode, Mode.ToStringValue()));
            builder.AppendLine(UIModel.SetParameterCommand(this, ControllerProperties.IntegrityAtackValue, IntegrityAttackValue.ToString(new NumberFormatInfo { NumberDecimalSeparator = "." })));
            builder.AppendLine(UIModel.SetParameterCommand(this, ControllerProperties.Start, Start));
            builder.AppendLine(UIModel.SetParameterCommand(this, ControllerProperties.Duration, Duration));
            return builder.ToString();
        }

        #endregion

        #endregion

        #region Commands

        private ICommand randomCommand;
        public ICommand RandomCommand
        {
            get { return randomCommand ?? (randomCommand = new ActionCommand<string>(ExecuteRandomCommand)); }
        }

        #endregion

        #region Helpers

        void ExecuteRandomCommand(string param)
        {
            if(param.ToLower().Equals("start")) SetStartRandom();
            else SetDurationRandom();
        }

        static int GetRandom()
        {
            return new Random().Next(1000000);
        }

        #endregion
    }
}