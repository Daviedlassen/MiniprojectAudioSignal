classdef Equalizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        LoadButton           matlab.ui.control.Button
        PlayButton           matlab.ui.control.Button
        ApplyEQButton        matlab.ui.control.Button
        EQSwitch             matlab.ui.control.ToggleSwitch
        EQSwitchLabel        matlab.ui.control.Label
        EqualizerKnobsPanel  matlab.ui.container.Panel
        BassKnob             matlab.ui.control.Knob
        MidKnob              matlab.ui.control.Knob
        TrebleKnob           matlab.ui.control.Knob
        TrebleKnobLabel      matlab.ui.control.Label
        MidKnobLabel         matlab.ui.control.Label
        BassKnobLabel        matlab.ui.control.Label
        ProcessedAxes        matlab.ui.control.UIAxes
        PreAxes              matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            global gain;
            global fs; 
            global t;

            [file, path] = uigetfile;
            filename = [path file];
            [gain, fs]= audioread(filename); 
            dt = 1/fs;
            N = length(gain);
            t = (0:N-1)*dt;
            plot(app.PreAxes,t,gain);
        end

        % Button pushed function: ApplyEQButton
        function ApplyEQButtonPushed(app, event)
            global gain;
            global fs; 
            global t;
            global gain_Filtered;

            Lp = myLowPassFilter(fs);
            Mid = myMidFilter(fs);
            Hp = myHighPassFilter(fs);

            gain_Lp = filter(Lp,gain)
            gain_Mid = filter(Mid,gain)
            gain_Hp = filter(Hp,gain)

            powerBass = 10^(app.BassKnob.Value/10);
            powerMid = 10^(app.MidKnob.Value/10);
            powerTreple = 10^(app.TrebleKnob.Value/10);

            gain_Filtered = powerBass*gain_Lp+powerMid*gain_Mid+powerTreple*gain_Hp;
            plot(app.ProcessedAxes,t,gain_Filtered);
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
    global gain;
    global fs;
    global gain_Filtered;
    
    % Persistent ariable to keep track of the audioplayer object
    persistent player;

    % Check if an audioplayer object exists and is currently playing
    if ~isempty(player) && isplaying(player)
        stop(player); % Stop the currently playing audio
    end

    if strcmp(app.EQSwitch.Value, 'Off')
        waittime = length(gain)/fs*1.1; 
        player = audioplayer(gain, fs);
        play(player);
        pause(waittime);

    else
        waittime = length(gain_Filtered)/fs*1.1; 
        player = audioplayer(gain_Filtered, fs);
        play(player);
        pause(waittime);
    end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create PreAxes
            app.PreAxes = uiaxes(app.UIFigure);
            title(app.PreAxes, 'Pre-processed')
            xlabel(app.PreAxes, 'Time (S)')
            ylabel(app.PreAxes, 'Amplitutde')
            zlabel(app.PreAxes, 'Z')
            app.PreAxes.Position = [388 213 232 184];

            % Create ProcessedAxes
            app.ProcessedAxes = uiaxes(app.UIFigure);
            title(app.ProcessedAxes, 'Processed')
            xlabel(app.ProcessedAxes, 'Time (S)')
            ylabel(app.ProcessedAxes, 'Amplitutde')
            zlabel(app.ProcessedAxes, 'Z')
            app.ProcessedAxes.Position = [23 181 341 249];

            % Create EqualizerKnobsPanel
            app.EqualizerKnobsPanel = uipanel(app.UIFigure);
            app.EqualizerKnobsPanel.Title = 'Equalizer Knobs';
            app.EqualizerKnobsPanel.BackgroundColor = [0.902 0.902 0.902];
            app.EqualizerKnobsPanel.Position = [40 15 341 148];

            % Create BassKnobLabel
            app.BassKnobLabel = uilabel(app.EqualizerKnobsPanel);
            app.BassKnobLabel.HorizontalAlignment = 'center';
            app.BassKnobLabel.Position = [40 7 32 22];
            app.BassKnobLabel.Text = 'Bass';

            % Create MidKnobLabel
            app.MidKnobLabel = uilabel(app.EqualizerKnobsPanel);
            app.MidKnobLabel.HorizontalAlignment = 'center';
            app.MidKnobLabel.Position = [157 6 25 22];
            app.MidKnobLabel.Text = 'Mid';

            % Create TrebleKnobLabel
            app.TrebleKnobLabel = uilabel(app.EqualizerKnobsPanel);
            app.TrebleKnobLabel.HorizontalAlignment = 'center';
            app.TrebleKnobLabel.Position = [263 7 39 22];
            app.TrebleKnobLabel.Text = 'Treble';

            % Create TrebleKnob
            app.TrebleKnob = uiknob(app.EqualizerKnobsPanel, 'continuous');
            app.TrebleKnob.Limits = [-10 10];
            app.TrebleKnob.Position = [258 54 50 50];

            % Create MidKnob
            app.MidKnob = uiknob(app.EqualizerKnobsPanel, 'continuous');
            app.MidKnob.Limits = [-10 10];
            app.MidKnob.Position = [145 53 50 50];

            % Create BassKnob
            app.BassKnob = uiknob(app.EqualizerKnobsPanel, 'continuous');
            app.BassKnob.Limits = [-10 10];
            app.BassKnob.Position = [31 54 50 50];

            % Create EQSwitchLabel
            app.EQSwitchLabel = uilabel(app.UIFigure);
            app.EQSwitchLabel.HorizontalAlignment = 'center';
            app.EQSwitchLabel.Position = [404 21 25 22];
            app.EQSwitchLabel.Text = 'EQ';

            % Create EQSwitch
            app.EQSwitch = uiswitch(app.UIFigure, 'toggle');
            app.EQSwitch.Position = [407 65 20 45];

            % Create ApplyEQButton
            app.ApplyEQButton = uibutton(app.UIFigure, 'push');
            app.ApplyEQButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyEQButtonPushed, true);
            app.ApplyEQButton.Position = [454 103 100 23];
            app.ApplyEQButton.Text = 'Apply EQ';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [454 69 100 23];
            app.PlayButton.Text = 'Play';

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [454 35 100 23];
            app.LoadButton.Text = 'Load';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Equalizer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end